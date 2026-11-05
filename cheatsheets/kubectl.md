# ☸️ kubectl Cheat Sheet

## Context & cluster
```bash
kubectl config get-contexts   ·   kubectl config current-context
kubectl config use-context NAME
kubectl config set-context --current --namespace=NS
kubectl cluster-info   ·   kubectl get nodes -o wide   ·   kubectl version
kubectl api-resources   ·   kubectl explain deployment.spec.strategy
```

## Get & describe
```bash
kubectl get pods -A                          # all namespaces
kubectl get pods -o wide --show-labels -l app=api
kubectl get deploy,rs,pods,svc,endpointslices
kubectl get pod NAME -o yaml
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
kubectl describe pod NAME                    # read Events bottom-up
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get pods -w                          # watch
```

## Create & change
```bash
kubectl apply -f file.yaml   ·   kubectl apply -f dir/   ·   kubectl apply -k kustomize-dir/
kubectl delete -f file.yaml
kubectl create deployment web --image=nginx:1.27-alpine --replicas=3
kubectl expose deployment web --port=80 --target-port=8080
kubectl run tmp --rm -it --restart=Never --image=busybox:1.36 -- sh
kubectl create deployment x --image=y --dry-run=client -o yaml > x.yaml    # generate YAML
kubectl edit deploy NAME   ·   kubectl patch ...   ·   kubectl label / annotate
```

## Debug
```bash
kubectl logs POD [-c CONTAINER] [-f] [--previous] [--tail=50]
kubectl logs -l app=api --prefix
kubectl exec -it POD -- sh
kubectl debug -it POD --image=busybox:1.36 --target=CONTAINER
kubectl port-forward svc/NAME 8080:80 [--address 0.0.0.0]
kubectl top nodes   ·   kubectl top pods               # needs metrics-server
kubectl auth can-i list pods --as=system:serviceaccount:NS:SA
```

## Deployments
```bash
kubectl scale deploy NAME --replicas=5
kubectl set image deploy/NAME CONTAINER=image:tag
kubectl set env deploy/NAME KEY=value
kubectl rollout status deploy/NAME   ·   kubectl rollout history deploy/NAME
kubectl rollout undo deploy/NAME [--to-revision=N]
kubectl rollout restart deploy/NAME
kubectl rollout pause / resume deploy/NAME
```

## Nodes
```bash
kubectl cordon NODE   ·   kubectl uncordon NODE
kubectl drain NODE --ignore-daemonsets --delete-emptydir-data
kubectl taint node NODE key=value:NoSchedule   (append - to remove)
kubectl label node NODE disktype=ssd
```

## Pod STATUS decoder
| STATUS | Look at |
|---|---|
| Pending | `describe` Events: resources, nodeSelector, taints, PVC |
| ImagePullBackOff | image name/tag, registry auth |
| CreateContainerConfigError | missing ConfigMap / Secret |
| CrashLoopBackOff | `logs --previous`, exit code, liveness probe |
| OOMKilled / 137 | memory limit |
| Running 0/1 | readiness probe, dependencies |
| Running 1/1, users fail | Service selector, endpoints, targetPort, DNS, NetworkPolicy |
