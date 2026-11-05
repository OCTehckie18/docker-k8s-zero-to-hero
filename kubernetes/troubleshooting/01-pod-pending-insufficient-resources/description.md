# K-01: Pods stuck in Pending *(class-slide scenario)*

## 📖 The story
"3 replicas desired, but they never start." The Deployment exists, nothing is crashing, and nothing is running.

## 🔥 Symptoms
- `kubectl get pods -n troubleshoot` → `Pending`, no restarts, no node assigned

## 🔍 Investigate
```bash
kubectl get pods -n troubleshoot -o wide            # NODE = <none>
kubectl describe pod -n troubleshoot -l app=ts-greedy | grep -A6 Events
kubectl get events -n troubleshoot --sort-by=.metadata.creationTimestamp | tail -5
kubectl describe node | grep -A8 'Allocated resources'
```
<details><summary>💡 Hint</summary>Pending = the scheduler couldn't find a node. The Events say exactly why. Compare what the Pod <b>requests</b> with what a node <b>has</b>.</details>
<details><summary>✅ Root cause & fix</summary>

Each Pod requests **64 CPUs** (`cpu: "64"`). Someone probably meant `64m`. No node is that big, so the scheduler reports `Insufficient cpu`. Fix the request to a realistic value: see [`fix.yaml`](fix.yaml).
</details>

## 🏭 Production lesson
Pending means **scheduling** problems: resources, nodeSelector/affinity, taints, or an unbound PVC. Check Events first. In the cloud, the Cluster Autoscaler can add nodes, but not 64-core ones if your node group is smaller.
