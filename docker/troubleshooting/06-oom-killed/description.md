# D-06: The worker dies silently

## 📖 The story
A report-generation worker keeps restarting. There's no stack trace and no error in the logs: it just vanishes and comes back.

## 🔥 Symptoms
- `ts-worker` restarts several times, then ends up `Exited (137)`
- Logs stop mid-way with no error

## 🎯 Your mission
Prove **why** it dies and make it finish.

## 🔍 Investigate
```bash
docker ps -a --filter name=ts-worker
docker logs ts-worker
docker inspect ts-worker --format 'OOMKilled={{.State.OOMKilled}} ExitCode={{.State.ExitCode}} Restarts={{.RestartCount}}'
docker inspect ts-worker --format 'MemoryLimit={{.HostConfig.Memory}}'
docker stats --no-stream ts-worker
```

<details><summary>💡 Hint</summary>
Exit code 137 = 128 + 9 (SIGKILL). Who sends SIGKILL without asking?
</details>
<details><summary>✅ Root cause & fix</summary>

The worker needs about 150MB but the container limit is **48MB**. The kernel's OOM killer terminates it (exit 137, `OOMKilled=true`), and the restart policy starts it again: a crash loop.

Fix the limit to match what the workload really needs (or reduce the app's memory use):
```bash
docker rm -f ts-worker
docker run -d --name ts-worker --label z2h.lab=ts --memory 256m python:3.12-alpine \
  python -c "print('loading report data...', flush=True); data = bytearray(150*1024*1024); print('report done', flush=True)"
sleep 3; docker logs ts-worker
```
</details>

## 🏭 Production lesson
Set limits based on **measured** usage plus headroom, and alert on OOM kills. In Kubernetes this appears as `OOMKilled` in `kubectl describe pod` (scenario K-08).
