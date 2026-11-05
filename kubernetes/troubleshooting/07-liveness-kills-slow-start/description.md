# K-07: A healthy app that keeps getting killed

## 📖 The story
The app takes ~25 seconds to warm up. Someone added a liveness probe. Now it never finishes starting.

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot -l app=ts-slow -w             # Running → restart → CrashLoopBackOff
kubectl describe pod -n troubleshoot -l app=ts-slow | grep -E 'Liveness|Killing|Unhealthy' | head -5
kubectl logs -n troubleshoot -l app=ts-slow --previous
```
<details><summary>💡 Hint</summary>The logs show "simulating slow startup" and then nothing; there's no crash. Who is killing it, and after how many seconds?</details>
<details><summary>✅ Root cause & fix</summary>

Liveness starts checking immediately: 2 failures × 3s means the container is killed after ~6s, but the app needs ~25s to boot. It never gets there. Add a **startupProbe**: liveness only starts after startup succeeds. See [`fix.yaml`](fix.yaml).
</details>

## 🏭 Production lesson
JVM, .NET, ML-model and cache-warming apps hit this constantly, especially when a busy node makes startup slower than usual. Use startupProbes and keep liveness simple.
