#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup; ensure_api_image
docker network create --label "$LABEL" ts-net >/dev/null
say "Starting Redis and the API..."
docker run -d --name ts-redis --label "$LABEL" --network ts-net redis:7-alpine >/dev/null
docker run -d --name ts-api   --label "$LABEL" --network ts-net -p 8085:8080 -e REDIS_HOST=localhost z2h/api:1.0 >/dev/null
sleep 2
docker ps --filter "label=$LABEL" --format 'table {{.Names}}\t{{.Status}}'
say "Calling the API:"
curl -s "localhost:8085/api/vote?option=cats"; echo
