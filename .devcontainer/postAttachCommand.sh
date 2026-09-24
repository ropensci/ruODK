#!/usr/bin/env bash
# Runs each time a tool attaches to the devcontainer. See issue #170.
#
# Seeds the local ODK Central with the fixtures from inst/extdata/odkc, then
# points ruODK at it by writing ~/.Renviron and ~/.bashrc. Idempotent: the seed
# skips forms and submissions that already exist.
set -euo pipefail

echo "postAttach: wiring ruODK to the local ODK Central test stack.."

cd "${containerWorkspaceFolder:-/workspaces/ruODK}"

# 1. A CA bundle that trusts both the public CAs and the local stack. See the
#    comment in ca-bundle.sh for why it must be a merge and not the local CA.
CA_BUNDLE="$PWD/.devcontainer/odkc/certs/ca-bundle.pem"
if ! .devcontainer/odkc/ca-bundle.sh "$CA_BUNDLE" >/dev/null; then
  echo "postAttach: WARNING could not build the CA bundle." >&2
  echo "postAttach: Is the test stack up? Try: docker compose --env-file" \
       ".devcontainer/.env -f .devcontainer/docker-compose.yml up -d --wait" >&2
  exit 0
fi
echo "postAttach: CA bundle at $CA_BUNDLE"

# 2. Seed. Throws away the throwaway admin if it is missing, and fills in
#    forms, submissions and attachments that are not there yet.
if ! Rscript data-raw/seed_odkc.R; then
  echo "postAttach: WARNING seeding failed. See the output above." >&2
  exit 0
fi

# 3. Point ruODK at the seeded stack. These are the local, throwaway
#    credentials that the seed creates, not the ruodk.getodk.cloud ones.
ODKC_TEST_URL="${ODKC_SEED_URL:-https://localhost:8383}"
ODKC_TEST_UN="${ODKC_SEED_UN:-ruodk@example.com}"
ODKC_TEST_PW="${ODKC_SEED_PW:-ruodk-local-password}"
ODKC_TEST_VERSION="${ODKC_TEST_VERSION:-2026.3.0}"

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

# 4. opencode CLI for agentic coding inside the container. Installed per user
#    into ~/.opencode/bin and skipped when already on PATH, so re-attaching
#    is cheap.
if ! command -v opencode >/dev/null 2>&1; then
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

# 5. Personal OpenCode Zen token. opencode reads OPENCODE_API_KEY straight
#    from the environment, so exporting it is the whole configuration.
#    Provide it as a PERSONAL Codespaces secret
#    (github.com/settings/codespaces, scoped to ropensci/ruODK), never as a
#    repository secret: anyone opening this repo as a codespace would
#    otherwise share your billed token. Without the secret this step is a
#    silent no-op and opencode stays unconfigured for that user.
if [ -n "${OPENCODE_API_KEY:-}" ]; then
  persist_shell_var "OPENCODE_API_KEY" "${OPENCODE_API_KEY}" ~/.bashrc
  echo "postAttach: OPENCODE_API_KEY found, exported for future shells."
fi
