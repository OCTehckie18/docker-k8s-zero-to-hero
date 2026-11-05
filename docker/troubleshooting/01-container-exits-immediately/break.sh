#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup; ensure_api_image
say "Starting the API with the 'new' run command..."
docker run -d --name ts-exits --label "$LABEL" -p 8085:8080 z2h/api:1.0 python server.py >/dev/null
sleep 2
docker ps -a --filter name=ts-exits --format 'table {{.Names}}\t{{.Status}}'
