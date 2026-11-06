# K00 Quiz: Kubernetes Foundations 🧠

50 questions. Answer each one **before** opening it. 40+ means you're ready for K01; 30–39, revisit the chapters you missed; under 30, go through [K00](README.md) once more.

---

## Part A: Concepts (20)

<details><summary><b>A1.</b> What is container orchestration?</summary>

Automatically deploying, scaling, connecting, healing and updating containers across a cluster of machines, based on a description of what you want.
</details>

<details><summary><b>A2.</b> Name four jobs an orchestrator does that a single Docker host doesn't.</summary>

Any four of: scheduling across machines, self-healing when nodes die, rolling updates and rollbacks across the fleet, service discovery and load balancing, autoscaling, distributing config and secrets, attaching persistent storage.
</details>

<details><summary><b>A3.</b> What does "Kubernetes" mean, and what is "K8s"?</summary>

Greek for "helmsman" (the one who steers the ship). K8s is a shorthand: K, then 8 letters, then s.
</details>

<details><summary><b>A4.</b> Which internal Google system inspired Kubernetes?</summary>

Borg (and its successor research, Omega).
</details>

<details><summary><b>A5.</b> Who owns Kubernetes today?</summary>

No single company. It's governed by the Cloud Native Computing Foundation (CNCF), part of the Linux Foundation, with contributors from across the industry.
</details>

<details><summary><b>A6.</b> What is a cluster?</summary>

A set of machines managed together by Kubernetes: a control plane plus worker nodes.
</details>

<details><summary><b>A7.</b> Imperative vs declarative: which one is Kubernetes, and why does it matter?</summary>

Declarative. You state the desired end state ("3 replicas") instead of step-by-step commands, so Kubernetes can keep re-creating that state when things change or fail.
</details>

<details><summary><b>A8.</b> Describe the reconciliation loop in four words.</summary>

Desired → observe → compare → act (repeated forever).
</details>

<details><summary><b>A9.</b> In a manifest, what's the difference between <code>spec</code> and <code>status</code>?</summary>

`spec` is the desired state that you write. `status` is the actual state that Kubernetes reports.
</details>

<details><summary><b>A10.</b> What is a Pod?</summary>

The smallest deployable unit: one or more containers that share a network identity (one IP) and can share volumes, scheduled together on one node.
</details>

<details><summary><b>A11.</b> Why do we normally create Deployments instead of bare Pods?</summary>

A bare Pod isn't replaced if it or its node dies. A Deployment (through a ReplicaSet) keeps the desired number of Pods running and handles rolling updates and rollbacks.
</details>

<details><summary><b>A12.</b> What does a ReplicaSet do?</summary>

Keeps exactly N identical Pods (matching its label selector) running, creating or deleting Pods as needed.
</details>

<details><summary><b>A13.</b> What problem does a Service solve?</summary>

Pods come and go, and their IPs change. A Service gives a stable virtual IP and DNS name, and load-balances across the matching Ready Pods.
</details>

<details><summary><b>A14.</b> How does a Service know which Pods belong to it?</summary>

Through its label selector: for example, `app=web` matches every Pod labelled `app=web`.
</details>

<details><summary><b>A15.</b> What is a namespace used for?</summary>

Grouping objects: separating teams, apps or environments within one cluster. It's also the scope for RBAC permissions, quotas and many policies.
</details>

<details><summary><b>A16.</b> ConfigMap vs Secret?</summary>

Both deliver configuration to Pods. Secrets are meant for sensitive data and can be protected separately (RBAC, encryption at rest), but they're only base64-encoded by default.
</details>

<details><summary><b>A17.</b> What is a PersistentVolumeClaim?</summary>

A request for storage ("1 GiB, read-write") that the cluster fulfils with a PersistentVolume. The data outlives the Pods that use it.
</details>

<details><summary><b>A18.</b> Do containers in the same Pod have the same IP?</summary>

Yes. They share the Pod's network namespace and reach each other via `localhost`.
</details>

<details><summary><b>A19.</b> Why should you never hard-code a Pod's IP address?</summary>

Pods are replaced all the time (crashes, rollouts, node failures), and a new Pod gets a new IP. Use the Service name.
</details>

<details><summary><b>A20.</b> Is desired state guaranteed?</summary>

No. It's *reconciled*. Kubernetes keeps trying, but if there aren't enough resources, or the image doesn't exist, the objects stay Pending or failing, and the reasons show up in events and status.
</details>

---

## Part B: Scenarios (10)

<details><summary><b>B1.</b> A worker node loses power at 3 a.m. What happens to the Pods of a 3-replica Deployment that were on it?</summary>

The node controller marks the node NotReady. After a timeout, its Pods are evicted, and the ReplicaSet controller sees fewer than 3 Ready Pods, so it creates replacements, which the scheduler places on healthy nodes. No human needed (if there's capacity).
</details>

<details><summary><b>B2.</b> You run <code>kubectl delete pod web-abc</code> to stop an app, and a new Pod appears. Why? How do you really stop it?</summary>

The Pod belongs to a ReplicaSet that restores the desired count. Change the desired state: `kubectl scale deployment web --replicas=0`, or delete the Deployment.
</details>

<details><summary><b>B3.</b> Traffic is about to jump 20× for an event. What Kubernetes features help?</summary>

Scaling the Deployment (manually or with a HorizontalPodAutoscaler), the scheduler spreading Pods, Services load-balancing across them, and a cluster autoscaler adding nodes if needed.
</details>

<details><summary><b>B4.</b> You must ship version 2 during business hours. What does a Deployment do for you?</summary>

A rolling update: it gradually starts v2 Pods and removes v1 Pods only once the new ones are Ready. You can roll back if something goes wrong (K06).
</details>

<details><summary><b>B5.</b> The checkout service needs to call the payment service, whose Pods move between nodes. How should it address them?</summary>

Through the payment Service's DNS name, for example `http://payment` (same namespace) or `payment.shop.svc.cluster.local`.
</details>

<details><summary><b>B6.</b> <code>kubectl create deployment</code> printed "created", but nothing is running a minute later. Is that a contradiction?</summary>

No. "Created" means the desired state was stored. Running depends on the controllers, the scheduler and the kubelet succeeding. Check `kubectl get pods`, `kubectl describe pod`, and the events.
</details>

<details><summary><b>B7.</b> Your team wants staging and production in one cluster without mixing objects. What do you use?</summary>

Namespaces (plus RBAC, quotas and NetworkPolicies for real separation). Many companies still use separate clusters for production.
</details>

<details><summary><b>B8.</b> The database password must not appear in the container image or in Git. Where does it go?</summary>

A Kubernetes Secret (ideally synced from an external secret manager), mounted into the Pod as a file or an environment variable at runtime.
</details>

<details><summary><b>B9.</b> The scheduler Pod crashes for two minutes. Do running apps go down?</summary>

No. Running Pods keep running; only *new* Pods wait to be scheduled. When the scheduler returns, it catches up.
</details>

<details><summary><b>B10.</b> A developer says, "We use Kubernetes, so we don't need Docker any more." Agree?</summary>

Partly. The cluster nodes don't need dockerd (they use containerd or CRI-O), but developers still commonly use Docker to build, test and run images locally. The images are standard OCI images either way.
</details>

---

## Part C: Architecture (10)

<details><summary><b>C1.</b> Which component is the only one that talks to etcd?</summary>

The kube-apiserver.
</details>

<details><summary><b>C2.</b> What does the kube-scheduler actually do, and what does it <i>not</i> do?</summary>

It chooses a node for each unscheduled Pod and records that choice (the binding). It does not start containers; the kubelet does.
</details>

<details><summary><b>C3.</b> What is a controller?</summary>

A loop that watches objects through the API server, compares desired with actual state, and acts to close the gap. Examples: the Deployment, ReplicaSet, Node and Job controllers.
</details>

<details><summary><b>C4.</b> What does the kubelet do?</summary>

The agent on each node: it watches for Pods assigned to its node, asks the container runtime (via CRI) to run them, runs their probes, and reports status to the API server.
</details>

<details><summary><b>C5.</b> What does kube-proxy do?</summary>

It programs node networking (iptables/IPVS) so that traffic to a Service's virtual IP is load-balanced to the Service's Ready Pods.
</details>

<details><summary><b>C6.</b> What is the CRI?</summary>

The Container Runtime Interface: a standard gRPC API the kubelet uses to talk to container runtimes such as containerd and CRI-O.
</details>

<details><summary><b>C7.</b> What does etcd store?</summary>

The cluster's entire state: every object's spec and status. Lose etcd without a backup and you lose the cluster's memory.
</details>

<details><summary><b>C8.</b> Why don't Kubernetes components call each other directly?</summary>

They all watch the API server and react to changes. That decoupling makes the system resilient (components can restart independently) and extensible (you can add your own controllers).
</details>

<details><summary><b>C9.</b> What gives every Pod its IP address?</summary>

The CNI (Container Network Interface) plugin, such as Calico, Cilium, Flannel or kindnet, invoked when the Pod's network sandbox is created.
</details>

<details><summary><b>C10.</b> What does the cloud-controller-manager do, and why isn't it on your laptop cluster?</summary>

It integrates with a cloud provider: load balancers, disks, node lifecycle. Local clusters such as kind and Docker Desktop have no cloud to talk to.
</details>

---

## Part D: Docker vs Kubernetes (5)

<details><summary><b>D1.</b> Docker vs Kubernetes, in one line each.</summary>

Docker builds, ships and runs containers on **one** machine. Kubernetes orchestrates containers across **many** machines.
</details>

<details><summary><b>D2.</b> What do a Docker host and a Kubernetes node have in common?</summary>

containerd (on many nodes), runc, the Linux kernel's namespaces and cgroups, and the OCI image format.
</details>

<details><summary><b>D3.</b> What was dockershim, and what happened to it?</summary>

An adapter that let the kubelet use Docker's daemon as its runtime. It was deprecated in v1.20 and removed in v1.24; nodes now use CRI runtimes like containerd or CRI-O directly.
</details>

<details><summary><b>D4.</b> Will an image built with <code>docker build</code> run on a cluster using containerd?</summary>

Yes. It's a standard OCI image.
</details>

<details><summary><b>D5.</b> Docker Compose vs Kubernetes: when would you choose each?</summary>

Compose: local development, CI tests, small single-host apps. Kubernetes: multi-machine production that needs self-healing, rolling updates, autoscaling and service discovery at scale.
</details>

---

## Part E: Troubleshooting (5)

<details><summary><b>E1.</b> <code>kubectl get pods</code> says "The connection to the server localhost:8080 was refused". What's wrong?</summary>

kubectl has no valid cluster configured: no kubeconfig, the wrong context, or the cluster isn't running. Check `kubectl config current-context`, then start or select the cluster.
</details>

<details><summary><b>E2.</b> A Pod has been <code>Pending</code> for 5 minutes. Which component couldn't do its job, and where do you look?</summary>

Usually the scheduler couldn't find a suitable node (not enough CPU or memory, a nodeSelector or taint mismatch, an unbound PVC). Look at `kubectl describe pod <name>` → Events.
</details>

<details><summary><b>E3.</b> The Pods are Running, but the Service doesn't respond. What do you check first?</summary>

Endpoints: `kubectl get endpointslices -l kubernetes.io/service-name=<svc>`. If there are none, the Service's selector doesn't match the Pods' labels, or the Pods aren't Ready. Then check the `targetPort`.
</details>

<details><summary><b>E4.</b> You created a Deployment and no Pods at all appear, not even Pending. Where do you look?</summary>

The ReplicaSet's events (`kubectl describe rs -l app=<name>`) or the namespace events. Admission rejections, such as a ResourceQuota being exceeded or a Pod Security violation, show up there, not on Pods.
</details>

<details><summary><b>E5.</b> You're about to run <code>kubectl delete namespace shop</code>. What should you check first, and why?</summary>

`kubectl config current-context`: which cluster are you on? Deleting a namespace deletes everything inside it, and doing it on production instead of staging is a classic outage.
</details>

---

### 🏆 Bonus
Draw the Kubernetes architecture from memory on a sheet of paper (control plane, nodes, arrows) and explain what happens after `kubectl create deployment` to a friend. If you can, you've mastered K00. 🎉

⬅️ [Back to K00](README.md) · ➡️ [K01: Tour of a Cluster](../01-cluster-tour/README.md)
