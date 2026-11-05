#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Recreating with a health check that targets the real port (8080)"
docker rm -f ts-health >/dev/null 2>&1
docker run -d --name ts-health --label "$LABEL" -p 8085:8080 \
  --health-cmd 'wget -qO- http://127.0.0.1:8080/healthz || exit 1' --health-interval 3s --health-retries 2 \
  z2h/api:1.0 >/dev/null
sleep 8
docker ps --filter name=ts-health --format 'table {{.Names}}\t{{.Status}}'
