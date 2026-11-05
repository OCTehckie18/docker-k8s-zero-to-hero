#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup; ensure_api_image
docker volume create --label "$LABEL" ts-uploads >/dev/null
# An old root-run job created the directory, so it is owned by root.
docker run --rm -v ts-uploads:/data alpine mkdir -p /data/uploads
say "Starting the uploader as non-root UID 10001..."
docker run -d --name ts-uploader --label "$LABEL" -v ts-uploads:/data z2h/api:1.0 \
  sh -c 'while true; do echo "$(date) saved upload" >> /data/uploads/uploads.log || exit 1; echo "saved"; sleep 2; done' >/dev/null
sleep 3
docker ps -a --filter name=ts-uploader --format 'table {{.Names}}\t{{.Status}}'
