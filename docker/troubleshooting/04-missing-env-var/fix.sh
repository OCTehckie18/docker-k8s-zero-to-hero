#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Recreating Postgres with POSTGRES_PASSWORD set"
docker rm -f ts-db >/dev/null 2>&1
docker run -d --name ts-db --label "$LABEL" -e POSTGRES_PASSWORD=devpass postgres:16-alpine >/dev/null
for _ in $(seq 1 20); do docker exec ts-db pg_isready -U postgres >/dev/null 2>&1 && break; sleep 1; done
docker exec ts-db psql -U postgres -tc 'select version();'
