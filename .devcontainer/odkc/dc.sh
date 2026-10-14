#!/usr/bin/env bash
# docker compose for the ruODK stack, shared by justfile recipes and
# .devcontainer/postAttachCommand.sh so the two cannot drift apart.
#
# Addresses the stack by its real compose project name, which depends on how
# it was launched (repo root -> `ruodk`, .devcontainer/ -> `devcontainer`,
# the devcontainer CLI -> its own name). A wrong name fails exactly as
# `service "service" is not running`. Detection mirrors the container's own
# compose labels when present. DOCKER_HOST defaults to the shared host
# socket from the docker-outside-of-docker feature.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

compose_project="$(docker inspect "$(cat /etc/hostname 2>/dev/null)" \
  --format '{{ index .Config.Labels "com.docker.compose.project" }}' \
  2>/dev/null || true)"
if [ -n "${compose_project:-}" ]; then
  export COMPOSE_PROJECT_NAME="${compose_project}"
fi
export DOCKER_HOST="${DOCKER_HOST:-unix:///var/run/docker-host.sock}"

exec docker compose --env-file "$repo_root/.devcontainer/.env" \
  -f "$repo_root/.devcontainer/docker-compose.yml" \
  -f "$repo_root/.devcontainer/docker-compose-dev.yml" "$@"
