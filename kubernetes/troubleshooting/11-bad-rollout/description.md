# K-11: The Friday-evening release is stuck

## 📖 The story
v2 was shipped at 17:55 on a Friday. CI says the deploy "timed out". Is production down?

## 🔍 Investigate
```bash
kubectl rollout status deploy/ts-shop -n troubleshoot --timeout=5s
kubectl get pods -n troubleshoot -l app=ts-shop
kubectl get rs -n troubleshoot -l app=ts-shop
kubectl rollout history deploy/ts-shop -n troubleshoot
kubectl describe pod -n troubleshoot -l app=ts-shop | grep -m3 -i 'failed\|back-off'
```
<details><summary>💡 Hint</summary>Count Ready Pods from the <b>old</b> ReplicaSet. Is anyone actually down? Then: what's the fastest safe way back?</details>
<details><summary>✅ Root cause & fix</summary>

The v2 image tag doesn't exist, so the new Pod is stuck in ImagePullBackOff. Thanks to `maxUnavailable: 0` and readiness, all 3 v1 Pods are **still serving**. Users are fine; only the rollout is stuck. Roll back:
```bash
kubectl rollout undo deploy/ts-shop -n troubleshoot
```
Then fix the tag in Git and ship properly on Monday. 🙂
</details>

## 🏭 Production lesson
Safe rollout settings turn a broken release into a non-event. Without readiness probes or with `maxUnavailable > 0`, this would have been an outage.
