#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup
say "Starting Postgres..."
docker run -d --name ts-db --label "$LABEL" postgres:16-alpine >/dev/null
sleep 3
docker ps -a --filter name=ts-db --format 'table {{.Names}}\t{{.Status}}'
