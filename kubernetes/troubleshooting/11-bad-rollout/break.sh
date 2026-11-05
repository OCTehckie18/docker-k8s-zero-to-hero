#!/usr/bin/env bash
# Deploy a good v1, then ship a broken v2.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$DIR/issue.yaml"
kubectl rollout status deploy/ts-shop -n troubleshoot --timeout=120s
echo "🚀 Shipping v2..."
kubectl set image deploy/ts-shop -n troubleshoot api=z2h/api:2.0-final-FINAL
kubectl annotate deploy/ts-shop -n troubleshoot kubernetes.io/change-cause="v2 friday evening hotfix" --overwrite
kubectl rollout status deploy/ts-shop -n troubleshoot --timeout=20s || true
