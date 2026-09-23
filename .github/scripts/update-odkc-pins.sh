#!/usr/bin/env bash
# Check ghcr.io for newer ODK Central images and bump the pins in lockstep.
#
# Usage: update-odkc-pins.sh [ROOT]   (default: git toplevel)
#
# Reads the current pins from .devcontainer/.env, compares them against the
# newest strict-semver (vX.Y.Z) tags published for
# ghcr.io/getodk/central-service and ghcr.io/getodk/pyxform-http, and, when a
# newer tag exists, rewrites every place that names the version:
#   .devcontainer/.env                  ODKC_IMAGE_TAG / ODKC_VERSION_PYXFORM
#   .devcontainer/docker-compose.yml    the ${VAR:-v...} fallbacks
#   .github/workflows/{R-CMD-check,test-coverage}.yaml
#                                       ODKC_TEST_VERSION / ODKC_VERSION
#                                       (bare semver for R/ru_setup.R)
#   .devcontainer/postAttachCommand.sh  the ODKC_TEST_VERSION default
#
# The image tag and the R semver must move together: the workflows declare
# the bare semver ("2026.3.0") while compose needs the v-prefixed ghcr.io tag
# ("v2026.3.0"), and mixing them up is exactly the "manifest unknown" failure
# the ODKC_IMAGE_TAG split was created to prevent. Never downgrades.
#
# A listed tag is not proof the image is usable: upstream can cut a release
# before its images finish building. Every candidate tag is pulled before it
# becomes a pin, so the update PR can never carry a "manifest unknown"
# failure into CI.
#
# Exit 0 whether or not anything changed (the caller diffs the tree).
# Prints a human summary, plus key=value lines to $GITHUB_OUTPUT when set.
set -euo pipefail

ROOT="${1:-$(git rev-parse --show-toplevel)}"
ENV_FILE="$ROOT/.devcontainer/.env"
COMPOSE_FILE="$ROOT/.devcontainer/docker-compose.yml"
POST_ATTACH="$ROOT/.devcontainer/postAttachCommand.sh"
WORKFLOWS=(
  "$ROOT/.github/workflows/R-CMD-check.yaml"
  "$ROOT/.github/workflows/test-coverage.yaml"
)

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "update-odkc-pins: required command '$1' not found" >&2
    exit 1
  }
}
need curl
need jq
need sort
need sed
need grep
need docker

# Print all tags of a getodk image on ghcr.io (anonymous token, public repos).
ghcr_tags() {
  local image="$1" token
  token="$(curl -fsSL "https://ghcr.io/token?scope=repository:getodk/${image}:pull" |
    jq -re '.token')"
  curl -fsSL -H "Authorization: Bearer ${token}" \
    "https://ghcr.io/v2/getodk/${image}/tags/list?n=1000" |
    jq -re '.tags[]'
}

# Newest strict-semver vX.Y.Z tag from a tag list on stdin. Skips rolling
# tags (latest, master, nightly) and pre-releases by construction.
latest_stable() {
  grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1
}

# True when $2 is a strictly newer semver than $1 (v-prefixed tags).
is_newer() {
  [ "$1" != "$2" ] &&
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n 1)" = "$2" ]
}

# Pull a candidate tag, retrying transient failures. Fatal when the tag is
# genuinely not pullable: callers must not pin it.
pull_verified() {
  local image="$1" tag="$2" attempt
  for attempt in 1 2 3; do
    if docker pull -q "ghcr.io/getodk/${image}:${tag}" >/dev/null 2>&1; then
      echo "update-odkc-pins: ghcr.io/getodk/${image}:${tag} pulls OK"
      return 0
    fi
    echo "update-odkc-pins: pull attempt ${attempt} failed for ${image}:${tag}" >&2
    sleep 10
  done
  echo "update-odkc-pins: ${image}:${tag} is not pullable; refusing to pin it" >&2
  exit 1
}

current_central="$(grep -E '^ODKC_IMAGE_TAG=' "$ENV_FILE" | cut -d= -f2)"
current_pyxform="$(grep -E '^ODKC_VERSION_PYXFORM=' "$ENV_FILE" | cut -d= -f2)"
[ -n "$current_central" ] || {
  echo "update-odkc-pins: ODKC_IMAGE_TAG not found in $ENV_FILE" >&2
  exit 1
}
[ -n "$current_pyxform" ] || {
  echo "update-odkc-pins: ODKC_VERSION_PYXFORM not found in $ENV_FILE" >&2
  exit 1
}

latest_central="$(ghcr_tags central-service | latest_stable)"
latest_pyxform="$(ghcr_tags pyxform-http | latest_stable)"

changed=false
if is_newer "$current_central" "$latest_central"; then
  echo "update-odkc-pins: central-service $current_central -> $latest_central"
  changed=true
else
  latest_central="$current_central"
  echo "update-odkc-pins: central-service $current_central already current"
fi
if is_newer "$current_pyxform" "$latest_pyxform"; then
  echo "update-odkc-pins: pyxform-http $current_pyxform -> $latest_pyxform"
  changed=true
else
  latest_pyxform="$current_pyxform"
  echo "update-odkc-pins: pyxform-http $current_pyxform already current"
fi

if [ "$changed" = true ]; then
  # Prove the candidates exist as pullable images before writing them
  # anywhere. CI would reject a bad tag anyway, but a red update PR is
  # noise; refuse it here instead.
  [ "$latest_central" = "$current_central" ] ||
    pull_verified central-service "$latest_central"
  [ "$latest_pyxform" = "$current_pyxform" ] ||
    pull_verified pyxform-http "$latest_pyxform"

  bare_central="${latest_central#v}"

  # .env pins (anchored full-line matches).
  sed -i "s/^ODKC_IMAGE_TAG=.*/ODKC_IMAGE_TAG=${latest_central}/" "$ENV_FILE"
  sed -i "s/^ODKC_VERSION_PYXFORM=.*/ODKC_VERSION_PYXFORM=${latest_pyxform}/" "$ENV_FILE"

  # Compose fallbacks.
  sed -i "s/ODKC_IMAGE_TAG:-v[^}]*/ODKC_IMAGE_TAG:-${latest_central}/" "$COMPOSE_FILE"
  sed -i "s/ODKC_VERSION_PYXFORM:-v[^}]*/ODKC_VERSION_PYXFORM:-${latest_pyxform}/" "$COMPOSE_FILE"

  # Workflow R semvers (bare X.Y.Z; the trailing ": " keeps
  # ODKC_VERSION_PYXFORM-style names out of the match).
  for wf in "${WORKFLOWS[@]}"; do
    sed -i -E "s/^([[:space:]]*ODKC_TEST_VERSION: ).*/\1${bare_central}/" "$wf"
    sed -i -E "s/^([[:space:]]*ODKC_VERSION: ).*/\1${bare_central}/" "$wf"
  done

  # Devcontainer default.
  sed -i "s/ODKC_TEST_VERSION:-[^}]*/ODKC_TEST_VERSION:-${bare_central}/" "$POST_ATTACH"

  # Fail closed: every file must now name exactly the intended values.
  grep -q "^ODKC_IMAGE_TAG=${latest_central}$" "$ENV_FILE"
  grep -q "^ODKC_VERSION_PYXFORM=${latest_pyxform}$" "$ENV_FILE"
  grep -q "ODKC_IMAGE_TAG:-${latest_central}}" "$COMPOSE_FILE"
  grep -q "ODKC_VERSION_PYXFORM:-${latest_pyxform}}" "$COMPOSE_FILE"
  for wf in "${WORKFLOWS[@]}"; do
    grep -qE "^[[:space:]]*ODKC_TEST_VERSION: ${bare_central}$" "$wf"
    grep -qE "^[[:space:]]*ODKC_VERSION: ${bare_central}$" "$wf"
  done
  grep -q "ODKC_TEST_VERSION:-${bare_central}}" "$POST_ATTACH"
  echo "update-odkc-pins: pins updated and verified"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "central_old=${current_central}"
    echo "central_new=${latest_central}"
    echo "pyxform_old=${current_pyxform}"
    echo "pyxform_new=${latest_pyxform}"
    echo "changed=${changed}"
  } >>"$GITHUB_OUTPUT"
fi
