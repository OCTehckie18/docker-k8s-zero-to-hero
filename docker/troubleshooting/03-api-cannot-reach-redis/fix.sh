#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Recreating the API with REDIS_HOST=ts-redis (the container name on ts-net)"
docker rm -f ts-api >/dev/null 2>&1
docker run -d --name ts-api --label "$LABEL" --network ts-net -p 8085:8080 -e REDIS_HOST=ts-redis z2h/api:1.0 >/dev/null
sleep 2
curl -s localhost:8085/readyz; echo
curl -s "localhost:8085/api/vote?option=cats"; echo
