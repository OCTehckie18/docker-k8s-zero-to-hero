# K-03: CrashLoopBackOff

## 📖 The story
After a "harmless" change to the start command, the Pod restarts over and over.

## 🔥 Symptoms
- STATUS `CrashLoopBackOff`, RESTARTS climbing

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot -l app=ts-crash
kubectl logs -n troubleshoot -l app=ts-crash --previous      # ⭐ logs of the crashed attempt
kubectl describe pod -n troubleshoot -l app=ts-crash | grep -A6 'Last State'
```
<details><summary>💡 Hint</summary>Exit code 2 from Python usually means "file not found". What does the command try to run?</details>
<details><summary>✅ Root cause & fix</summary>

`command: ["python", "server.py"]`, but the file is `app.py`. Remove the override: [`fix.yaml`](fix.yaml).
</details>

## 🏭 Production lesson
CrashLoopBackOff is a **symptom**. The cause is in `logs --previous` (app error), `describe` (OOMKilled, failing liveness probe), or the exit code: 1 app error · 2/127 bad command · 137 killed (OOM/liveness) · 143 SIGTERM.
