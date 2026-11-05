# D-08: The container is "unhealthy" but the app works

## 📖 The story
Monitoring is alerting: `ts-health` is **unhealthy**. A developer curls the app and it answers fine. "The health check is lying!" Is it?

## 🔥 Symptoms
- `docker ps` shows `(unhealthy)`
- `curl localhost:8085/healthz` → 200 OK

## 🎯 Your mission
Find what the health check actually runs and make it accurate.

## 🔍 Investigate
```bash
docker ps --filter name=ts-health
docker inspect ts-health --format '{{json .Config.Healthcheck}}'
docker inspect ts-health --format '{{range .State.Health.Log}}{{.ExitCode}}: {{.Output}}{{end}}'
docker exec ts-health sh -c 'netstat -tln 2>/dev/null || ss -tln'
```

<details><summary>💡 Hint</summary>
The health check runs <b>inside</b> the container. Which port does it call, and which port does the app listen on?
</details>
<details><summary>✅ Root cause & fix</summary>

The health check calls port **9090**, but the app listens on **8080**. The check is wrong, not the app. Health checks are code too, and they have bugs.

```bash
docker rm -f ts-health
docker run -d --name ts-health --label z2h.lab=ts -p 8085:8080 \
  --health-cmd 'wget -qO- http://127.0.0.1:8080/healthz || exit 1' --health-interval 3s --health-retries 2 \
  z2h/api:1.0
sleep 8; docker ps --filter name=ts-health
```
</details>

## 🏭 Production lesson
A misconfigured check is worse than none: in Kubernetes a wrong **liveness** probe restarts a perfectly healthy app forever, and a wrong **readiness** probe removes it from load balancing (scenarios K-06, K-07). Test probes like you test code.
