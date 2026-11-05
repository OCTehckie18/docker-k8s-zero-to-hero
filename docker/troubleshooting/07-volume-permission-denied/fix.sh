#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
say "Giving UID 10001 ownership of /data/uploads with a one-off root container"
docker run --rm -v ts-uploads:/data alpine chown -R 10001:10001 /data/uploads
docker start ts-uploader >/dev/null
sleep 5
docker logs --tail 3 ts-uploader
docker ps --filter name=ts-uploader --format 'table {{.Names}}\t{{.Status}}'
