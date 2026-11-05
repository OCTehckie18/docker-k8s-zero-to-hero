#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup; ensure_api_image
say "Starting Redis and the API on the default network..."
docker run -d --name ts-redis --label "$LABEL" redis:7-alpine >/dev/null
docker run -d --name ts-api   --label "$LABEL" -p 8085:8080 -e REDIS_HOST=ts-redis z2h/api:1.0 >/dev/null
sleep 2
curl -s localhost:8085/readyz; echo
