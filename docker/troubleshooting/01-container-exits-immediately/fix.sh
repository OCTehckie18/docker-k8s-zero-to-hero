#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Recreating the container with the image's default CMD (python app.py)"
docker rm -f ts-exits >/dev/null 2>&1
docker run -d --name ts-exits --label "$LABEL" -p 8085:8080 z2h/api:1.0 >/dev/null
sleep 2
curl -s localhost:8085/api/info && echo && ok "API is up on :8085"
