#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
ts_cleanup
mkdir -p /tmp/z2h-ts-build/fixtures
cd /tmp/z2h-ts-build || exit 1
echo '{"feature_flags": {"new_checkout": true}}' > config.json
echo '{"huge": "test data"}' > fixtures/orders.json
cat > Dockerfile <<'EOF'
FROM busybox
COPY config.json /app/config.json
CMD ["cat", "/app/config.json"]
EOF
printf '*.json\n' > .dockerignore
say "Building in /tmp/z2h-ts-build ..."
docker build -t z2h/ts-build .
