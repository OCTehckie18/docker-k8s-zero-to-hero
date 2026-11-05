# K-10: PVC stuck in Pending

## 📖 The story
The manifests were copied from the production cluster. The database Pod sits in `Pending` forever.

## 🔍 Investigate
```bash
kubectl get pod,pvc -n troubleshoot
kubectl describe pvc ts-data -n troubleshoot | grep -A5 Events
kubectl describe pod ts-db -n troubleshoot | grep -A5 Events
kubectl get storageclass
```
<details><summary>💡 Hint</summary>The Pod waits for the PVC; the PVC waits for a StorageClass. Does the requested class exist in <i>this</i> cluster?</details>
<details><summary>✅ Root cause & fix</summary>

`storageClassName: fast-ssd` doesn't exist here, so no provisioner will ever create the volume. Use a class that exists, or omit the field to get the default: [`fix.yaml`](fix.yaml). `storageClassName` is immutable, so the runner deletes and recreates the PVC.
</details>

## 🏭 Production lesson
StorageClass names differ between clusters and clouds (`gp3`, `premium-rwo`, `standard`...). Parameterise them per environment.
