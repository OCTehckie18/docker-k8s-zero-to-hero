#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Running a tag that exists: nginx:1.27-alpine"
docker rm -f ts-img >/dev/null 2>&1
docker run -d --name ts-img --label "$LABEL" -p 8085:80 nginx:1.27-alpine >/dev/null
sleep 1; curl -sI localhost:8085 | head -2
