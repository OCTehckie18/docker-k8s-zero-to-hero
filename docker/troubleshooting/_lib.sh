#!/usr/bin/env bash
# Shared helpers for Docker troubleshooting scenarios. Sourced by break.sh / fix.sh.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LABEL="z2h.lab=ts"

say()  { printf '\033[1;36m▶ %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m⚠ %s\033[0m\n' "$*"; }

# Build the course API image if it is not present yet.
ensure_api_image() {
  if ! docker image inspect z2h/api:1.0 >/dev/null 2>&1; then
    say "Building z2h/api:1.0 (first time only)..."
    docker build -q -t z2h/api:1.0 "$REPO_ROOT/apps/api" >/dev/null
  fi
}

# Remove everything any troubleshooting scenario created.
# shellcheck disable=SC2046  # word splitting of the ID lists is intended
ts_cleanup() {
  docker rm -f $(docker ps -aq --filter "label=$LABEL") >/dev/null 2>&1 || true
  docker network rm $(docker network ls -q --filter "label=$LABEL") >/dev/null 2>&1 || true
  docker volume rm $(docker volume ls -q --filter "label=$LABEL") >/dev/null 2>&1 || true
  rm -rf /tmp/z2h-ts-build
}
