# K-05: Endpoints exist, connections still refused

## 📖 The story
This time the selector is correct and the endpoints are there. The client still fails.

## 🔍 Investigate
```bash
kubectl logs -n troubleshoot ts-client --tail=5
kubectl get endpointslices -n troubleshoot -l kubernetes.io/service-name=ts-api -o wide   # look at PORTS
kubectl get svc ts-api -n troubleshoot -o yaml | grep -A4 ports
kubectl get pod -n troubleshoot -l app=ts-api -o jsonpath='{.items[0].spec.containers[0].ports}'; echo
POD=$(kubectl get pod -n troubleshoot -l app=ts-api -o name | head -1)
kubectl exec -n troubleshoot ts-client -- wget -qO- -T 2 http://$(kubectl get $POD -n troubleshoot -o jsonpath='{.status.podIP}'):8080/healthz
```
<details><summary>💡 Hint</summary>Calling the Pod IP directly on 8080 works. Calling the Service fails. Which port does the Service forward <i>to</i>?</details>
<details><summary>✅ Root cause & fix</summary>

`targetPort: 80`, but the container listens on **8080**. Fix it: [`fix.yaml`](fix.yaml). Even better, use **named ports** (`targetPort: http`) so the Service follows the container definition.
</details>

## 🏭 Production lesson
Test the layers separately: Pod IP:port (does the app listen?) → Service (is the mapping right?) → DNS name → Gateway/Ingress.
