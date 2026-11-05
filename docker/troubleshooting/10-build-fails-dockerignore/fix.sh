#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Adding an exception for config.json to .dockerignore"
printf '*.json\n!config.json\n' > /tmp/z2h-ts-build/.dockerignore
docker build -q -t z2h/ts-build /tmp/z2h-ts-build >/dev/null && ok "build passed"
docker run --rm z2h/ts-build
