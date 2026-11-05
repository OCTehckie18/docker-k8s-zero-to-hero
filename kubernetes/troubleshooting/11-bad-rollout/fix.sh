#!/usr/bin/env bash
kubectl rollout history deploy/ts-shop -n troubleshoot
kubectl rollout undo deploy/ts-shop -n troubleshoot
kubectl rollout status deploy/ts-shop -n troubleshoot --timeout=120s
kubectl get pods -n troubleshoot -l app=ts-shop
