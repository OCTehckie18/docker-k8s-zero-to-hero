# K-13: Security hardening broke everything

## 📖 The story
Security added an egress NetworkPolicy: "the client may only talk to the API on 8080". Correct in theory. Since then, the client fails every request.

## 🔥 Symptoms
- `kubectl logs -f ts-client -n troubleshoot` shows `❌ FAILED`, and each failure takes **~20 seconds** to arrive
- (The very first line may be ✅: a brand-new Pod can win a short race before the policy is enforced.)

## 🔍 Investigate
```bash
kubectl logs -n troubleshoot ts-client --tail=3
kubectl get networkpolicy -n troubleshoot -o yaml | grep -A12 egress
kubectl exec -n troubleshoot ts-client -- nslookup ts-api                     # fails?
IP=$(kubectl get svc ts-api -n troubleshoot -o jsonpath='{.spec.clusterIP}')
kubectl exec -n troubleshoot ts-client -- wget -qO- -T 2 http://$IP:8080/healthz     # works by IP!
```
<details><summary>💡 Hint 1</summary>Look at the timestamps in the client log: each failure takes ~20 seconds. Instant failures usually mean <i>connection refused</i> (nothing listening). Slow failures mean <i>timeouts</i>: packets are being dropped. Who drops packets on purpose?</details>
<details><summary>💡 Hint 2</summary>By IP it works; by name it doesn't. What has to happen before the client can connect to <code>ts-api</code>?</details>
<details><summary>✅ Root cause & fix</summary>

Resolving `ts-api` requires a DNS query to CoreDNS (kube-system, port 53), and the egress policy blocks it. Allow DNS explicitly: [`fix.yaml`](fix.yaml).
</details>

## 🏭 Production lesson
Every egress policy needs a DNS rule. It's the #1 NetworkPolicy outage. *(Requires a CNI that enforces NetworkPolicy: kind, Calico, Cilium, Killercoda.)*
