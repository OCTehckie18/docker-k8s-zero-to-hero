#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup
say "Starting web server #1 on host port 8085"
docker run -d --name ts-web-1 --label "$LABEL" -p 8085:80 nginx:1.27-alpine >/dev/null
say "Starting web server #2 on host port 8085..."
docker run -d --name ts-web-2 --label "$LABEL" -p 8085:80 nginx:1.27-alpine
docker ps -a --filter name=ts-web --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
