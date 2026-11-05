# K-08: OOMKilled

## 📖 The story
The nightly report service restarts every few seconds. Its logs end mid-sentence.

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot -l app=ts-report
kubectl describe pod -n troubleshoot -l app=ts-report | grep -A5 'Last State'
kubectl logs -n troubleshoot -l app=ts-report --previous
kubectl get pod -n troubleshoot -l app=ts-report -o jsonpath='{.items[0].spec.containers[0].resources}'; echo
```
<details><summary>💡 Hint</summary><code>Reason: OOMKilled</code>, <code>Exit Code: 137</code>. Compare what it needs with what it's allowed.</details>
<details><summary>✅ Root cause & fix</summary>

The process needs about 150MB, but the memory limit is 64Mi. The kernel kills it the moment it crosses the limit. Raise the limit to fit real usage plus headroom: [`fix.yaml`](fix.yaml). Or fix the memory use.
</details>

## 🏭 Production lesson
Memory limits are hard walls. Size them from measured peak usage (`kubectl top`, Prometheus), and alert on OOMKilled events.
