#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup
say "Upgrading nginx to 1.99.99..."
docker run -d --name ts-img --label "$LABEL" -p 8085:80 nginx:1.99.99-alpine
echo "exit code of docker run: $?"
