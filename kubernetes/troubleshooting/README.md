# ☸️ Kubernetes Troubleshooting Arena

15 real production failures. Each one **breaks your cluster on purpose**. Find the evidence, explain the root cause, fix it, and prove it's fixed.

## How to run
From the repository root:
```bash
./labs.sh                 # interactive menu
./labs.sh k8s 04          # break K-04
./labs.sh k8s 04 fix      # apply the reference fix
./labs.sh k8s clean       # delete the scenario namespaces
```
Everything runs in the **`troubleshoot`** namespace (K-12 adds `ts-backend`), so it never collides with your lab work. Remember `-n troubleshoot` in your commands.

Each folder holds `description.md` (story, symptoms, investigation commands, hints, and the answer, collapsed), `issue.yaml` (the broken state), and `fix.yaml` (the reference fix). Some also have `break.sh`/`fix.sh`.

Scenarios with a **`ts-client`** Pod simulate a real user. `kubectl logs -f ts-client -n troubleshoot` shows ✅ / ❌ every 2 seconds, so you **see** the moment your fix lands.

## The debugging ladder 🪜
```
1. kubectl get pods -n troubleshoot -o wide          what state? which node? restarts?
2. kubectl describe pod <pod> -n troubleshoot        read Events bottom-up
3. kubectl logs <pod> -n troubleshoot [--previous]   what did the app say before dying?
4. kubectl get events -n troubleshoot --sort-by=.metadata.creationTimestamp
5. kubectl get svc,endpointslices -n troubleshoot    is traffic routed to Ready Pods?
6. kubectl exec / kubectl debug                      test from inside: DNS, ports, files
```

## STATUS → where to look
| You see | It usually means | Look at |
|---|---|---|
| `Pending` | can't be scheduled | `describe pod` Events (resources, selectors, taints, PVC) |
| `ContainerCreating` (stuck) | volume / network / secret problem | `describe pod` Events |
| `ErrImagePull` / `ImagePullBackOff` | wrong image name/tag or registry auth | Events → the pull error message |
| `CreateContainerConfigError` | missing ConfigMap / Secret / key | `describe pod` |
| `CrashLoopBackOff` | the process keeps exiting | `logs --previous`, exit code, `Last State` |
| `OOMKilled` / exit 137 | over the memory limit | resources vs real usage |
| `Running` but `0/1` | readiness failing | probe config, `/readyz`, dependencies |
| `Running 1/1` but users fail | Service or network | selector, endpoints, targetPort, DNS, NetworkPolicy |

## Scenarios
| # | Scenario | Skill | Level |
|---|---|---|---|
| [K-01](01-pod-pending-insufficient-resources/description.md) | Pods stuck in Pending *(slide)* | scheduling, requests | 🟢 |
| [K-02](02-imagepullbackoff/description.md) | ImagePullBackOff | images, events | 🟢 |
| [K-03](03-crashloopbackoff/description.md) | CrashLoopBackOff | `logs --previous`, exit codes | 🟢 |
| [K-04](04-service-selector-mismatch/description.md) | Pods Running, Service dead *(slide)* | labels, endpoints | 🟡 |
| [K-05](05-wrong-target-port/description.md) | Endpoints exist, still refused | ports, layered testing | 🟡 |
| [K-06](06-readiness-probe-failing/description.md) | Running but never Ready | readiness probes | 🟡 |
| [K-07](07-liveness-kills-slow-start/description.md) | A healthy app keeps getting killed | liveness vs startup probes | 🟡 |
| [K-08](08-oomkilled/description.md) | OOMKilled | memory limits | 🟢 |
| [K-09](09-createcontainerconfigerror/description.md) | CreateContainerConfigError | Secrets, namespaces | 🟢 |
| [K-10](10-pvc-pending/description.md) | PVC stuck in Pending | StorageClasses | 🟡 |
| [K-11](11-bad-rollout/description.md) | The Friday-evening release | rollouts, rollback | 🟡 |
| [K-12](12-dns-wrong-namespace/description.md) | DNS across namespaces | CoreDNS, FQDNs | 🟡 |
| [K-13](13-networkpolicy-blocks-dns/description.md) | Hardening broke everything | NetworkPolicy egress + DNS | 🔴 |
| [K-14](14-rbac-forbidden/description.md) | 403 from the Kubernetes API | RBAC, ServiceAccounts | 🔴 |
| [K-15](15-service-links-env-collision/description.md) | The mystery `REDIS_PORT` variable | service links, env vars | 🔴 |

## Want more?
35 more scenarios (affinity, taints, CGroups, disk pressure, ingress, SELinux, PID collisions, …) in
👉 [troubleshoot-kubernetes-like-a-pro](https://github.com/vellankikoti/troubleshoot-kubernetes-like-a-pro)
