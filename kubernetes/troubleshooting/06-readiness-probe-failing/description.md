# K-06: Running but never Ready

## 📖 The story
A new readiness probe was added "for safety". Now the Pods are `Running` but `0/1`, and nobody gets served.

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot -l app=ts-api                 # READY 0/1, RESTARTS 0
kubectl describe pod -n troubleshoot -l app=ts-api | grep -E 'Readiness|Warning' | head -4
kubectl get endpointslices -n troubleshoot -l kubernetes.io/service-name=ts-api -o wide
POD=$(kubectl get pod -n troubleshoot -l app=ts-api -o name | head -1)
kubectl exec -n troubleshoot $POD -- wget -qO- localhost:8080/ready  ; echo
kubectl exec -n troubleshoot $POD -- wget -qO- localhost:8080/readyz ; echo
```
<details><summary>💡 Hint</summary>RESTARTS = 0 means liveness is fine. What does the probe call, and what does that path return?</details>
<details><summary>✅ Root cause & fix</summary>

The probe calls `/ready`, which returns **404**. The app's endpoint is `/readyz`. Not-ready Pods are removed from the Service, so there are no endpoints and every request fails. Fix the path: [`fix.yaml`](fix.yaml).
</details>

## 🏭 Production lesson
A wrong readiness probe silently takes your **whole** service out of rotation. Test probes locally (`curl` the exact path and port) before shipping them.
