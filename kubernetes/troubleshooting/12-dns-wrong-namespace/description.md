# K-12: "bad address": DNS across namespaces

## 📖 The story
The platform team moved the `inventory` service into its own namespace, `ts-backend`. Since then the client (in `troubleshoot`) can't find it, although the Service is clearly there.

## 🔍 Investigate
```bash
kubectl logs -n troubleshoot ts-client --tail=3
kubectl get svc -A | grep inventory
kubectl exec -n troubleshoot ts-client -- nslookup inventory
kubectl exec -n troubleshoot ts-client -- cat /etc/resolv.conf
kubectl exec -n troubleshoot ts-client -- nslookup inventory.ts-backend.svc.cluster.local
```
<details><summary>💡 Hint</summary>Look at the <code>search</code> line in resolv.conf. Which namespace does the short name <code>inventory</code> expand to?</details>
<details><summary>✅ Root cause & fix</summary>

A short name resolves **within the client's own namespace** (`inventory.troubleshoot.svc...`), which doesn't exist. Use `inventory.ts-backend` or the full name `inventory.ts-backend.svc.cluster.local`: [`fix.yaml`](fix.yaml).
</details>

## 🏭 Production lesson
Use fully qualified names for cross-namespace calls in config. And check that NetworkPolicies allow the cross-namespace path.
