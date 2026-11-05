# K-04: Pods Running, Service dead *(class-slide scenario)*

## 📖 The story
"Running does not prove the app is reachable." Both API Pods are `Running 1/1`, yet every user request fails.

## 🔥 Symptoms
- `kubectl logs -n troubleshoot ts-client -f` → `❌ FAILED` forever
- Pods: all `Running`

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot --show-labels
kubectl get svc ts-api -n troubleshoot -o wide            # SELECTOR column
kubectl get endpointslices -n troubleshoot -l kubernetes.io/service-name=ts-api
kubectl describe svc ts-api -n troubleshoot | grep -E 'Selector|Endpoints'
```
<details><summary>💡 Hint</summary>A Service sends traffic to Pods whose labels match <b>all</b> of its selector. Compare them character by character.</details>
<details><summary>✅ Root cause & fix</summary>

The Service selects `tier: api`, but the Pods are labelled `tier: backend`. No match means no endpoints, so connections are refused. Fix the selector: [`fix.yaml`](fix.yaml), or
`kubectl patch svc ts-api -n troubleshoot -p '{"spec":{"selector":{"app":"ts-api","tier":"backend"}}}'`
</details>

## 🏭 Production lesson
"Service has no endpoints" is the first thing to check when a running app is unreachable. Generate labels and selectors from one place (Helm/Kustomize) to avoid typos.
