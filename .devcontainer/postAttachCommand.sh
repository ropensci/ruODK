#!/usr/bin/env bash
# Runs each time a tool attaches to the devcontainer. See issue #170.
#
# Installs the opencode CLI and wires a personal OPENCODE_API_KEY when
# present (first, so opencode works even if the steps below fail), then
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
#    already ships it (see Dockerfile); this fallback install covers images
#    built before that line existed. Skipped when the binary is already in
#    place, so re-attaching is cheap. Runs first so opencode works even when
#    the stack seeding below fails.
if [ ! -x "${HOME}/.opencode/bin/opencode" ] && ! command -v opencode >/dev/null 2>&1; then
  echo "postAttach: installing opencode.."
  curl -fsSL https://opencode.ai/install | bash
fi
if [[ ":${PATH}:" != *":${HOME}/.opencode/bin:"* ]]; then
  export PATH="${HOME}/.opencode/bin:${PATH}"
fi
if ! grep -q '\.opencode/bin' ~/.bashrc 2>/dev/null; then
  printf 'export PATH="$HOME/.opencode/bin:$PATH"\n' >>~/.bashrc
fi
if ! opencode --version >/dev/null 2>&1; then
  echo "postAttach: WARNING opencode is not runnable." >&2
fi

# 1b. Posit air R formatter for the `air-format` pre-commit hook, which needs
#    `air` on PATH. The dev image already ships it (see Dockerfile); this
#    fallback install covers images built before that line existed. Skipped
#    when the binary is already in place, so re-attaching is cheap. Installs
#    flat into ~/.local/bin (this installer creates no `bin/` subdir, so the
#    directory itself must be the install prefix) without touching shell rc
#    files; PATH is wired below. Pinned to the same version as the Dockerfile.
#    The `||` keeps a failed fallback install from aborting the stack seeding
#    below under `set -e`.
if ! command -v air >/dev/null 2>&1; then
  echo "postAttach: installing air.."
  export AIR_INSTALL_DIR="${HOME}/.local/bin" AIR_NO_MODIFY_PATH=1
  curl -LsSf https://github.com/posit-dev/air/releases/download/0.11.0/air-installer.sh | sh \
    || echo "postAttach: WARNING air install failed." >&2
  unset AIR_INSTALL_DIR AIR_NO_MODIFY_PATH
fi
if [[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
  printf 'export PATH="$HOME/.local/bin:$PATH"\n' >>~/.bashrc
fi
if ! air --version >/dev/null 2>&1; then
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

# 3. The seed below shells out to `docker compose exec service`
#    (ODKC_COMPOSE in data-raw/seed_odkc.R). Two things must hold for that
#    to reach the running stack: the stack must be up, and compose must
#    address it by its real project name, which depends on how it was
#    launched (repo root -> `ruodk`, .devcontainer/ -> `devcontainer`, the
#    devcontainer CLI -> its own name). A wrong name fails exactly as
#    `service "service" is not running`. Detect the project from this
#    container's own compose labels when present, then start the stack if it
#    is down (start-only, never recreate: see below) before seeding.
if command -v docker >/dev/null 2>&1; then
  compose_project="$(docker inspect "$(cat /etc/hostname 2>/dev/null)" \
    --format '{{ index .Config.Labels "com.docker.compose.project" }}' \
    2>/dev/null || true)"
  if [ -n "${compose_project:-}" ]; then
    export COMPOSE_PROJECT_NAME="${compose_project}"
  fi
  if ! docker compose --env-file .devcontainer/.env \
    -f .devcontainer/docker-compose.yml \
    -f .devcontainer/docker-compose-dev.yml up -d --no-recreate --wait nginx; then
    echo "postAttach: WARNING the ODK Central test stack failed to start." >&2
    docker compose --env-file .devcontainer/.env \
      -f .devcontainer/docker-compose.yml \
      -f .devcontainer/docker-compose-dev.yml ps 2>/dev/null || true
    docker compose --env-file .devcontainer/.env \
      -f .devcontainer/docker-compose.yml \
      -f .devcontainer/docker-compose-dev.yml logs --tail 30 certs service \
      2>/dev/null || true
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
  echo "postAttach: Is the test stack up? Try: docker compose --env-file" \
       ".devcontainer/.env -f .devcontainer/docker-compose.yml up -d --wait" >&2
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
ODKC_TEST_VERSION="${ODKC_TEST_VERSION:-2026.3.0}"

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
echo "postAttach: run  devtools::test()  to check the suite."
