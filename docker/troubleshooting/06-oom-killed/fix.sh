#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Re-running the worker with a 256m limit"
docker rm -f ts-worker >/dev/null 2>&1
docker run -d --name ts-worker --label "$LABEL" --memory 256m \
  python:3.12-alpine \
  python -c "print('loading report data...', flush=True); data = bytearray(150*1024*1024); print('report done', flush=True)" >/dev/null
sleep 4
docker logs ts-worker
docker inspect ts-worker --format 'OOMKilled={{.State.OOMKilled}} ExitCode={{.State.ExitCode}}'
