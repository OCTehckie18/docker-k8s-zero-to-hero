# K-14: 403 Forbidden from the Kubernetes API

## 📖 The story
A small monitoring tool lists Pods through the Kubernetes API. It's deployed and running, but it reports nothing.

## 🔍 Investigate
```bash
kubectl logs -n troubleshoot ts-watcher --tail=3
kubectl get pod ts-watcher -n troubleshoot -o jsonpath='{.spec.serviceAccountName}'; echo
kubectl auth can-i list pods -n troubleshoot --as=system:serviceaccount:troubleshoot:pod-watcher
kubectl get rolebindings -n troubleshoot
```
<details><summary>💡 Hint</summary>HTTP 403 means authenticated (Kubernetes knows who it is) but <b>not authorised</b>. What has this ServiceAccount been granted?</details>
<details><summary>✅ Root cause & fix</summary>

The ServiceAccount `pod-watcher` has no permissions; RBAC denies by default. Grant exactly what it needs (`get/list/watch pods` in this namespace) with a Role + RoleBinding: [`fix.yaml`](fix.yaml). The logs switch to `HTTP 200` within seconds; no restart needed.
</details>

## 🏭 Production lesson
Operators, CI jobs, and controllers fail this way after being moved to a new namespace or cluster. `kubectl auth can-i --as=...` is your friend. Grant the minimum; never cluster-admin.
