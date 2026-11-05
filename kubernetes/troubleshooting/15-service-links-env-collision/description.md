# K-15: "invalid literal for int()": the mystery variable

## 📖 The story
A worker runs perfectly with `docker run`. On Kubernetes it crashes instantly. Nobody set `REDIS_PORT` anywhere, yet the error is about `REDIS_PORT`. 👻

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot -l app=ts-worker
kubectl logs -n troubleshoot -l app=ts-worker --previous | tail -3
kubectl get deploy ts-worker -n troubleshoot -o yaml | grep -A3 env     # nothing sets REDIS_PORT!
kubectl get svc -n troubleshoot
kubectl run envcheck -n troubleshoot --rm -it --restart=Never --image=busybox:1.36 -- sh -c 'env | grep REDIS'
```
<details><summary>💡 Hint</summary>Look at what <code>envcheck</code> printed. Where could <code>REDIS_PORT=tcp://10.96...</code> come from, given there's a Service named <code>redis</code>?</details>
<details><summary>✅ Root cause & fix</summary>

For every Service in the namespace, Kubernetes injects Docker-links-style variables into new Pods: `REDIS_SERVICE_HOST`, `REDIS_PORT=tcp://10.96.x.x:6379`, and more. The app reads `REDIS_PORT` expecting `6379` and crashes on `int("tcp://...")`.

Fix: `enableServiceLinks: false` in the Pod spec: [`fix.yaml`](fix.yaml). Or name your app variables so they can't collide (e.g. `APP_REDIS_PORT`).
</details>

## 🏭 Production lesson
Real-world classic: it broke the course's own app while this lab was being written. Disable service links in production manifests; you should use DNS anyway.
