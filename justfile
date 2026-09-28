#!/usr/bin/env just --justfile
# https://github.com/casey/just
# Shortcuts for ruODK development: local ODK Central test stack + R tooling.
# Run from the package root. Docker recipes assume the devcontainer
# (docker-outside-of-docker feature); R recipes assume devtools and friends.
# Unlike ckanr, secrets live in .devcontainer/.env and are passed to compose
# via --env-file, so there is no `set dotenv-load` here.

# List all recipes
default:
  @just --list

alias bs := bootstrap

# ---------------------------------------------------------------------------#
# Local ODK Central test stack (mirrors .devcontainer/postAttachCommand.sh)
# ---------------------------------------------------------------------------#

# Full bootstrap: start stack, build CA bundle, seed fixtures
bootstrap: stack_up ca_bundle stack_seed

# Start the local ODK Central stack (never recreate: app shares nginx netns)
stack_up:
  #!/usr/bin/env bash
  set -euo pipefail
  # Never recreate: app shares nginx's network namespace, so recreating nginx
  # orphans our network. Project detection mirrors postAttachCommand.sh.
  compose_project="$(docker inspect "$(cat /etc/hostname 2>/dev/null)" --format '{{{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null || true)"
  if [ -n "${compose_project:-}" ]; then export COMPOSE_PROJECT_NAME="${compose_project}"; fi
  DOCKER_HOST=unix:///var/run/docker-host.sock docker compose --env-file .devcontainer/.env -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose-dev.yml up -d --no-recreate --wait nginx

# Build the merged CA bundle (public CAs + local test CA)
ca_bundle:
  # libcurl replaces (not extends) its CA store from CURL_CA_BUNDLE,
  # so never point it at ca.crt on its own.
  .devcontainer/odkc/ca-bundle.sh .devcontainer/odkc/certs/ca-bundle.pem

# Seed the local Central with fixtures from inst/extdata/odkc (idempotent)
stack_seed:
  Rscript data-raw/seed_odkc.R

# Show stack status and prove the API serves HTTPS (public endpoint, no auth)
stack_status:
  #!/usr/bin/env bash
  set -euo pipefail
  compose_project="$(docker inspect "$(cat /etc/hostname 2>/dev/null)" --format '{{{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null || true)"
  if [ -n "${compose_project:-}" ]; then export COMPOSE_PROJECT_NAME="${compose_project}"; fi
  DOCKER_HOST=unix:///var/run/docker-host.sock docker compose --env-file .devcontainer/.env -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose-dev.yml ps
  curl -sk https://localhost:8383/v1/config/public | head -c 500; echo

# Tail stack logs
stack_logs:
  #!/usr/bin/env bash
  set -euo pipefail
  compose_project="$(docker inspect "$(cat /etc/hostname 2>/dev/null)" --format '{{{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null || true)"
  if [ -n "${compose_project:-}" ]; then export COMPOSE_PROJECT_NAME="${compose_project}"; fi
  DOCKER_HOST=unix:///var/run/docker-host.sock docker compose --env-file .devcontainer/.env -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose-dev.yml logs --tail 100

# Stop the local ODK Central stack
stack_stop:
  #!/usr/bin/env bash
  set -euo pipefail
  # Stop all dev services; app shares nginx's network namespace, so stopping
  # nginx alone would leave this container broken.
  compose_project="$(docker inspect "$(cat /etc/hostname 2>/dev/null)" --format '{{{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null || true)"
  if [ -n "${compose_project:-}" ]; then export COMPOSE_PROJECT_NAME="${compose_project}"; fi
  DOCKER_HOST=unix:///var/run/docker-host.sock docker compose --env-file .devcontainer/.env -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose-dev.yml stop

# ---------------------------------------------------------------------------#
# R tooling (alternative to VS Code tasks via Ctrl-Shift-B)
# ---------------------------------------------------------------------------#

# R: Document package
doc:
  #!/usr/bin/env Rscript
  devtools::document()

# R: run tests (needs the local stack: `just bootstrap` first, RU_VERBOSE=TRUE)
test:
  #!/usr/bin/env Rscript
  devtools::test()

# R: test coverage via covr
coverage:
  #!/usr/bin/env Rscript
  devtools::test_coverage()

# R: check package
check:
  #!/usr/bin/env Rscript
  devtools::check()

# R: lint package (backstop for `just fmt`)
lint:
  #!/usr/bin/env Rscript
  lintr::lint_package()

# Format R code with air (enforced by the air-format pre-commit hook)
fmt:
  #!/usr/bin/env bash
  air format .
