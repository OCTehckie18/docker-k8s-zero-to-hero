#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup; ensure_api_image
say "Starting the API with a health check..."
docker run -d --name ts-health --label "$LABEL" -p 8085:8080 \
  --health-cmd 'wget -qO- http://127.0.0.1:9090/healthz || exit 1' --health-interval 3s --health-retries 2 \
  z2h/api:1.0 >/dev/null
sleep 10
docker ps --filter name=ts-health --format 'table {{.Names}}\t{{.Status}}'
curl -s localhost:8085/healthz; echo "   <- yet the app answers"
