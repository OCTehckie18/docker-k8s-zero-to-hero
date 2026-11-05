#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Attaching both containers to a user-defined network (which has DNS)"
docker network create --label "$LABEL" ts-net >/dev/null 2>&1
docker network connect ts-net ts-redis 2>/dev/null
docker network connect ts-net ts-api 2>/dev/null
sleep 1
curl -s localhost:8085/readyz; echo
curl -s "localhost:8085/api/vote?option=dogs"; echo
