# K-02: ImagePullBackOff

## 📖 The story
A routine nginx "upgrade" was merged. The new Pod never starts.

## 🔥 Symptoms
- `ErrImagePull`, then `ImagePullBackOff`

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot
kubectl describe pod -n troubleshoot -l app=ts-web | grep -A8 Events
kubectl get deploy ts-web -n troubleshoot -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```
<details><summary>💡 Hint</summary>Read the exact message after <code>Failed to pull image</code>: is it "not found", "unauthorized", or "toomanyrequests"?</details>
<details><summary>✅ Root cause & fix</summary>

The tag `nginx:1.99.99-alpine` doesn't exist (`not found`). Point it at a real tag: [`fix.yaml`](fix.yaml), or `kubectl set image deploy/ts-web -n troubleshoot web=nginx:1.27-alpine`.

| Message | Cause |
|---|---|
| `not found` / `manifest unknown` | wrong tag |
| `pull access denied` / `unauthorized` | typo in name, or private registry without `imagePullSecrets` |
| `toomanyrequests` | Docker Hub rate limit |
</details>

## 🏭 Production lesson
`BackOff` means Kubernetes retries with growing delays (up to 5 minutes). CI should verify the image exists before deploying. Pin tags or digests.
