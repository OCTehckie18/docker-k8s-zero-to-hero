#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Publishing web server #2 on a free host port (8086)"
docker rm -f ts-web-2 >/dev/null 2>&1
docker run -d --name ts-web-2 --label "$LABEL" -p 8086:80 nginx:1.27-alpine >/dev/null
sleep 1
docker ps --filter name=ts-web --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
curl -s -o /dev/null -w '8085 -> %{http_code}\n' localhost:8085
curl -s -o /dev/null -w '8086 -> %{http_code}\n' localhost:8086
