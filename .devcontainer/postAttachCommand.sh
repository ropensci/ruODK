#!/usr/bin/env bash
# Runs each time a tool attaches to the devcontainer. See issue #170.
#
# Verifies the system-wide opencode CLI and wires a personal OPENCODE_API_KEY
# when present (first, so opencode works even if the steps below fail), then
# seeds the local ODK Central with the fixtures from inst/extdata/odkc, then
# points ruODK at it by writing ~/.Renviron and ~/.bashrc. Idempotent: the seed
# skips forms and submissions that already exist.
set -euo pipefail

echo "postAttach: wiring ruODK to the local ODK Central test stack.."

cd "${containerWorkspaceFolder:-/workspaces/ruODK}"

persist_shell_var() {
  local var="$1" val="$2" file="$3"
  grep -v "export ${var}=" "${file}" 2>/dev/null > "${file}.tmp" || true
  printf "export %s='%s'\n" "${var}" "${val}" >> "${file}.tmp"
  mv "${file}.tmp" "${file}"
}

persist_renv_var() {
  local var="$1" val="$2" file="$3"
  grep -v "^${var}=" "${file}" 2>/dev/null > "${file}.tmp" || true
  printf "%s='%s'\n" "${var}" "${val}" >> "${file}.tmp"
  mv "${file}.tmp" "${file}"
}

# 1. opencode CLI for agentic coding inside the container. The dev image
#    ships it system-wide in /usr/local/bin (see Dockerfile; pattern mirrors
#    ropensci/ckanr), so every shell (bash, zsh, non-interactive) and the
#    VS Code server find it with no PATH wiring. Only verified here: a
#    missing binary means an old image, fixed by Rebuild Container. Runs
#    first so the check lands even when the stack seeding below fails.
if ! command -v opencode >/dev/null 2>&1; then
  echo "postAttach: WARNING opencode is not installed. Rebuild the container." >&2
elif ! opencode --version >/dev/null 2>&1; then
  echo "postAttach: WARNING opencode is not runnable." >&2
fi

# 1b. Posit air R formatter for the `air-format` pre-commit hook, which needs
#    `air` on PATH. The dev image ships it system-wide in /usr/local/bin
#    (see Dockerfile), so every shell finds it with no PATH wiring. Only
#    verified here: a missing binary means an old image, fixed by Rebuild
#    Container.
if ! command -v air >/dev/null 2>&1; then
  echo "postAttach: WARNING air is not installed. Rebuild the container." >&2
elif ! air --version >/dev/null 2>&1; then
  echo "postAttach: WARNING air is not runnable." >&2
fi

# 2. Personal OpenCode Go token. Both the opencode (Zen) and opencode-go
#    providers read OPENCODE_API_KEY straight from the environment, so
#    exporting it is the whole authentication. The config below additionally
#    defaults opencode to a Go model; change it with /models or by editing
#    ~/.config/opencode/opencode.json (never overwritten once present).
#    Provide the key as a PERSONAL Codespaces secret
#    (github.com/settings/codespaces, scoped to ropensci/ruODK), never as a
#    repository secret: anyone opening this repo as a codespace would
#    otherwise share your billed token. Without the secret this step is a
#    silent no-op and opencode stays unconfigured for that user. Runs first
#    so the token lands even when the stack seeding below fails.
if [ -n "${OPENCODE_API_KEY:-}" ]; then
  persist_shell_var "OPENCODE_API_KEY" "${OPENCODE_API_KEY}" ~/.bashrc
  echo "postAttach: OPENCODE_API_KEY found, exported for future shells."
  if [ ! -f ~/.config/opencode/opencode.json ]; then
    mkdir -p ~/.config/opencode
    printf '%s\n' '{"$schema":"https://opencode.ai/config.json","model":"opencode-go/muse-spark-1.3-contributor"}' \
      >~/.config/opencode/opencode.json
    echo "postAttach: opencode default model set to Go (muse-spark-1.3-contributor)."
  fi
fi

# 2b. ODK Docs MCP server for opencode (https://odk-docs.mcp.kapa.ai).
#    The server requires a Bearer token: without one opencode lists the
#    server but its tools fail at call time. Provide the token as a PERSONAL
#    Codespaces secret named KAPA_API_KEY (same scoping rules as
#    OPENCODE_API_KEY above, never a repository secret).
#    The entry is merged into ~/.config/opencode/opencode.json with python3
#    so an existing config (model, providers, other servers) is preserved;
#    the file is created with the default Go model when missing. Idempotent:
#    re-attaching only refreshes the token header (an emptied secret removes
#    it), and a deliberately removed server is re-added.
mkdir -p ~/.config/opencode
KAPA_API_KEY="${KAPA_API_KEY:-}" python3 - <<'EOF'
import json, os
cfg_path = os.path.expanduser("~/.config/opencode/opencode.json")
try:
    with open(cfg_path) as f:
        cfg = json.load(f)
except (OSError, ValueError):
    cfg = {
        "$schema": "https://opencode.ai/config.json",
        "model": "opencode-go/muse-spark-1.3-contributor",
    }
cfg.setdefault("mcp", {})["odk-docs"] = {
    "type": "remote",
    "url": "https://odk-docs.mcp.kapa.ai",
    "enabled": True,
}
token = os.environ.get("KAPA_API_KEY", "")
if token:
    cfg["mcp"]["odk-docs"]["headers"] = {"Authorization": f"Bearer {token}"}
else:
    cfg["mcp"]["odk-docs"].pop("headers", None)
with open(cfg_path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
EOF
echo "postAttach: opencode ODK Docs MCP server configured."

# 3. The seed below shells out to `docker compose exec service`
#    (ODKC_COMPOSE in data-raw/seed_odkc.R). Two things must hold for that
#    to reach the running stack: the stack must be up, and compose must
#    address it by its real project name. .devcontainer/odkc/dc.sh wraps
#    both (project detection plus the shared DOCKER_HOST socket), so this
#    script and the justfile recipes cannot drift apart. Start the stack
#    if it is down (start-only, never recreate: see below) before seeding.
DC=".devcontainer/odkc/dc.sh"
if command -v docker >/dev/null 2>&1; then
  if ! "$DC" up -d --no-recreate --wait nginx; then
    echo "postAttach: WARNING the ODK Central test stack failed to start." >&2
    "$DC" ps 2>/dev/null || true
    "$DC" logs --tail 30 certs service 2>/dev/null || true
    exit 0
  fi
  # --no-recreate above is load-bearing, not just speed: app shares nginx's
  # network namespace (network_mode: service:nginx in docker-compose-dev.yml),
  # so recreating nginx under this live container orphans our network and DNS
  # dies (git: "Could not resolve host"). Image/config upgrades arrive via
  # Rebuild Container, never via postAttach.
  #
  # Self-check for that orphaned state (e.g. nginx was recreated by other
  # means while we stayed up): external DNS is the canary. This only warns;
  # recovery is recreating this container (VS Code: Rebuild Container).
  if command -v getent >/dev/null 2>&1 && ! getent hosts github.com >/dev/null 2>&1; then
    echo "postAttach: WARNING external DNS fails from this container." >&2
    echo "postAttach: If nginx was recreated while app stayed up, our shared" >&2
    echo "postAttach: network namespace is stale. Rebuild Container to recover." >&2
  fi
else
  echo "postAttach: WARNING no docker CLI, cannot start the test stack." >&2
  exit 0
fi

# 4. A CA bundle that trusts both the public CAs and the local stack. See the
#    comment in ca-bundle.sh for why it must be a merge and not the local CA.
CA_BUNDLE="$PWD/.devcontainer/odkc/certs/ca-bundle.pem"
if ! .devcontainer/odkc/ca-bundle.sh "$CA_BUNDLE" >/dev/null; then
  echo "postAttach: WARNING could not build the CA bundle." >&2
  echo "postAttach: Is the test stack up? Try: just stack_up" >&2
  exit 0
fi
echo "postAttach: CA bundle at $CA_BUNDLE"

# 5. Seed. Throws away the throwaway admin if it is missing, and fills in
#    forms, submissions and attachments that are not there yet.
if ! Rscript data-raw/seed_odkc.R; then
  echo "postAttach: WARNING seeding failed. See the output above." >&2
  exit 0
fi

# 6. Point ruODK at the seeded stack. These are the local, throwaway
#    credentials that the seed creates, not the ruodk.getodk.cloud ones.
ODKC_TEST_URL="${ODKC_SEED_URL:-https://localhost:8383}"
ODKC_TEST_UN="${ODKC_SEED_UN:-ruodk@example.com}"
ODKC_TEST_PW="${ODKC_SEED_PW:-ruodk-local-password}"
ODKC_TEST_VERSION="${ODKC_TEST_VERSION:-2026.3.1}"

touch ~/.bashrc ~/.Renviron

# Form and project ids come from inst/extdata/odkc/manifest.json and match the
# values in CONTRIBUTING.md. They are not secrets.
for kv in \
  "ODKC_TEST_URL=${ODKC_TEST_URL}" \
  "ODKC_TEST_UN=${ODKC_TEST_UN}" \
  "ODKC_TEST_PW=${ODKC_TEST_PW}" \
  "ODKC_TEST_PID=1" \
  "ODKC_TEST_PID_ENC=2" \
  "ODKC_TEST_PP=ThePassphrase" \
  "ODKC_TEST_FID=Flora-Quadrat-04" \
  "ODKC_TEST_FID_ZIP=Locations" \
  "ODKC_TEST_FID_ATT=Flora-Quadrat-04-att" \
  "ODKC_TEST_FID_GAP=Flora-Quadrat-04-gap" \
  "ODKC_TEST_FID_WKT=Locations" \
  "ODKC_TEST_FID_ENC=Locations" \
  "ODKC_TEST_FID_I8N0=I8n_no_lang" \
  "ODKC_TEST_FID_I8N1=I8n_label_lng" \
  "ODKC_TEST_FID_I8N2=I8n_label_choices" \
  "ODKC_TEST_FID_I8N3=I8n_no_lang_choicefilter" \
  "ODKC_TEST_FID_I8N4=I8n_lang_choicefilter" \
  "ODKC_TEST_VERSION=${ODKC_TEST_VERSION}" \
  "RU_VERBOSE=TRUE" \
  "RU_TIMEZONE=Australia/Perth" \
  "RU_RETRIES=3"
do
  persist_shell_var "${kv%%=*}" "${kv#*=}" ~/.bashrc
  persist_renv_var "${kv%%=*}" "${kv#*=}" ~/.Renviron
done

# RU_VERBOSE must be TRUE for ru_msg_warn() to emit anything. It returns NULL
# silently when FALSE (R/ru_msg.R), and several tests use expect_warning().
persist_shell_var "CURL_CA_BUNDLE" "${CA_BUNDLE}" ~/.bashrc
persist_renv_var "CURL_CA_BUNDLE" "${CA_BUNDLE}" ~/.Renviron

echo "postAttach: done. ruODK now targets ${ODKC_TEST_URL}."
echo 'postAttach: run just test to check the suite.'
