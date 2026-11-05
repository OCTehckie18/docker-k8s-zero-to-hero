#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup
say "Starting the report worker (memory limit 48m)..."
docker run -d --name ts-worker --label "$LABEL" --memory 48m --memory-swap 48m --restart on-failure:5 \
  python:3.12-alpine \
  python -c "print('loading report data...', flush=True); data = bytearray(150*1024*1024); print('report done', flush=True)" >/dev/null
sleep 6
docker ps -a --filter name=ts-worker --format 'table {{.Names}}\t{{.Status}}'
