# K-09: CreateContainerConfigError

## 📖 The story
The app works in staging. In this namespace the Pod never even starts, and there are no logs at all.

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot -l app=ts-config
kubectl describe pod -n troubleshoot -l app=ts-config | grep -A4 -i warning
kubectl get secrets -n troubleshoot
```
<details><summary>💡 Hint</summary>No logs means the container was never created. Kubernetes couldn't build its environment. What does it reference that might not exist here?</details>
<details><summary>✅ Root cause & fix</summary>

The Pod references Secret `ts-db-credentials`, which exists in staging but not in this namespace (`secret "ts-db-credentials" not found`). Create it: [`fix.yaml`](fix.yaml). The kubelet retries and the Pod starts by itself.
</details>

## 🏭 Production lesson
Secrets and ConfigMaps are **namespaced** and must exist before the Pod starts. Deploy them with the app (same Helm chart / Kustomize base), or sync them with External Secrets Operator.
