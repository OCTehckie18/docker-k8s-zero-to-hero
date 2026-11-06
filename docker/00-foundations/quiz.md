# D00 Quiz: Docker Foundations 🧠

50 questions. Try each one **before** opening the answer. Score yourself: 40+ means you're ready for D01; 30–39, re-read the chapters you missed; under 30, go through [D00](README.md) once more. It's worth it.

---

## Part A: Concepts (20)

<details><summary><b>A1.</b> In one sentence, what problem does Docker solve?</summary>

Software behaves differently on different machines because the environments differ. Docker packages the app **with** everything it needs, so it runs the same everywhere.
</details>

<details><summary><b>A2.</b> What is a container image?</summary>

A read-only, versioned package of an application plus its runtime, libraries and files, together with metadata (default command, ports, environment). A template for containers.
</details>

<details><summary><b>A3.</b> What is a container?</summary>

A running (or stopped) instance of an image: ordinary processes on the host, isolated by namespaces, limited by cgroups, with a thin writable layer on top of the image.
</details>

<details><summary><b>A4.</b> In the phone-packaging story, what does Docker correspond to?</summary>

The whole packing-and-shipping system: the tools that build the package (image), move it (registries), and unbox it (run containers).
</details>

<details><summary><b>A5.</b> Why are software containers named after shipping containers?</summary>

Shipping containers standardised the box, so every crane, ship and truck can move any cargo without caring what's inside. Software containers standardise the package, so every machine can run any app the same way.
</details>

<details><summary><b>A6.</b> Name three technologies that provided container-like isolation before Docker.</summary>

Any three of: chroot (1979), FreeBSD Jails (2000), Solaris Zones (2004), Linux namespaces, cgroups (2008), LXC (2008).
</details>

<details><summary><b>A7.</b> What did Docker add that made containers mainstream?</summary>

Simplicity and portability: the Dockerfile, layered and shareable images, Docker Hub, and one consistent CLI and workflow (build, push, run) for every developer.
</details>

<details><summary><b>A8.</b> What does "the container shares the host kernel" mean?</summary>

There's no separate operating-system kernel inside a container. All containers on a host make their system calls to the same Linux kernel; they bring only their own files and libraries.
</details>

<details><summary><b>A9.</b> What is a Dockerfile?</summary>

A text file of step-by-step instructions (`FROM`, `RUN`, `COPY`, `CMD`…) that `docker build` follows to create an image. The recipe.
</details>

<details><summary><b>A10.</b> Image vs container: which one is immutable?</summary>

The image. Containers get their own writable layer; the image layers never change.
</details>

<details><summary><b>A11.</b> How many containers can you start from one image?</summary>

As many as your machine's resources allow. The image is never "used up".
</details>

<details><summary><b>A12.</b> What do namespaces do, in five words?</summary>

Limit what a process can **see**.
</details>

<details><summary><b>A13.</b> What do cgroups do, in five words?</summary>

Limit what a process can **use** (CPU, memory, I/O, number of processes).
</details>

<details><summary><b>A14.</b> What is an image layer?</summary>

A read-only set of filesystem changes produced by one build step (for example, the files added by `RUN pip install …`). An image is a stack of layers.
</details>

<details><summary><b>A15.</b> What is copy-on-write?</summary>

When a container modifies a file from a read-only layer, the file is first copied into the container's writable layer and changed there. The original layer stays untouched.
</details>

<details><summary><b>A16.</b> What is a registry? Name two.</summary>

A server that **stores and distributes** images: the central cold store. It never builds them; `docker build` does, and `docker push` delivers them. For example: Docker Hub, GitHub Container Registry (GHCR), Amazon ECR, Google Artifact Registry, Azure ACR, Harbor.
</details>

<details><summary><b>A17.</b> What's the difference between a tag and a digest?</summary>

A tag (`1.27-alpine`, `latest`) is a human-friendly label that can be moved to different content. A digest (`sha256:…`) is a fingerprint of the exact content and never changes.
</details>

<details><summary><b>A18.</b> What does the "OCI" standard guarantee?</summary>

A common image format and runtime specification, so images built by one tool (such as Docker) run on any compliant runtime (containerd, CRI-O, Podman…).
</details>

<details><summary><b>A19.</b> What is a volume, and why do we need it?</summary>

Storage managed outside a container's layers. Data written to a container's writable layer disappears with `docker rm`; data in a volume survives. Use volumes for databases and uploads.
</details>

<details><summary><b>A20.</b> Why do containers usually start faster than VMs?</summary>

A container start is just starting a process with namespaces and cgroups. A VM has to boot an entire operating system.
</details>

---

## Part B: Scenarios (10)

<details><summary><b>B1.</b> Your app works on your laptop but crashes in production with "module not found". How would containers have prevented this?</summary>

The module would be installed **inside the image** at build time. Production would run the exact same image, so the module couldn't be missing.
</details>

<details><summary><b>B2.</b> You need to run a Python 2.7 legacy tool and a Python 3.12 app on the same server. Containers or not?</summary>

Containers are perfect here. Each image brings its own Python version; they run side by side without conflicts, which is very hard to arrange directly on one OS.
</details>

<details><summary><b>B3.</b> A teammate fixed a bug by running <code>docker exec</code> and editing a file inside the production container. What will happen at the next deployment?</summary>

The fix disappears. The new container starts from the image, which doesn't include the edit. Fix it in the code or Dockerfile, rebuild, and redeploy.
</details>

<details><summary><b>B4.</b> You delete and recreate your database container, and all data is gone. What went wrong?</summary>

The data was stored in the container's writable layer, which is deleted with the container. Mount a **volume** at the database's data directory.
</details>

<details><summary><b>B5.</b> A colleague says, "Let's put the database password in the Dockerfile with ENV." Why is that a bad idea?</summary>

Anyone who can pull the image can read it (`docker inspect`, `docker history`). Pass secrets at runtime instead (environment variables, secret files, a secret manager).
</details>

<details><summary><b>B6.</b> You pull <code>myapp:latest</code> on Monday and again on Friday, and the behaviour changed. Why?</summary>

`latest` is a movable tag: someone pushed a new image under the same name. Pin a version tag or a digest for predictable deployments.
</details>

<details><summary><b>B7.</b> Your team must run a Windows-only application on Linux servers. Will containers solve this?</summary>

No. Linux containers share a Linux kernel and can't run Windows binaries natively. Use a Windows VM, or Windows servers with Windows containers.
</details>

<details><summary><b>B8.</b> You start 20 containers from the same 500 MB image. Roughly how much extra disk do the image layers use?</summary>

Almost none beyond the first 500 MB. Read-only layers are shared; each container adds only its small writable layer.
</details>

<details><summary><b>B9.</b> One container is using all the CPU and slowing down everything else on the host. Which Docker feature prevents this?</summary>

cgroup limits: for example, `--cpus 1`. The container is throttled to its share.
</details>

<details><summary><b>B10.</b> A hosting company runs untrusted code from thousands of different customers. Plain containers, VMs, or something else?</summary>

Stronger isolation is wise: VMs, or sandboxes and micro-VMs (gVisor, Kata Containers, Firecracker) that combine container convenience with VM-like boundaries. A shared-kernel bug could otherwise affect every tenant.
</details>

---

## Part C: Docker architecture (10)

<details><summary><b>C1.</b> In the breakfast-cafe analogy, who is the billing counter and who is the head chef?</summary>

The billing counter is the **Docker CLI**: it takes your order, gives you a token and passes it on. The head chef is the **Docker daemon (dockerd)**, which runs the kitchen.
</details>

<details><summary><b>C2.</b> How does the CLI talk to the daemon?</summary>

Through the Docker REST API: HTTP requests, usually over a Unix socket (`/var/run/docker.sock`), or over TCP/SSH to a remote engine.
</details>

<details><summary><b>C3.</b> Name the chain of components from your command to a running process.</summary>

CLI → REST API → dockerd → containerd → shim → runc → Linux kernel (namespaces, cgroups) → container process.
</details>

<details><summary><b>C4.</b> What does runc do, and when does it exit?</summary>

It asks the kernel to create the namespaces, apply the cgroups, mount the root filesystem and start the container's process. It exits once the container is running; the shim stays as the parent.
</details>

<details><summary><b>C5.</b> Why does containerd use a shim process?</summary>

So containers don't depend on dockerd or containerd staying alive. Those can restart or upgrade without killing running containers, and the shim keeps the container's stdio and exit status.
</details>

<details><summary><b>C6.</b> Which component pulls images from a registry when you run <code>docker run</code>?</summary>

The Docker daemon handles the pull (in newer engines, images are stored through containerd's image store). The CLI only sends the request.
</details>

<details><summary><b>C7.</b> What is "Docker Engine"?</summary>

The server-side package: the dockerd daemon and its API, together with containerd and runc.
</details>

<details><summary><b>C8.</b> Why is access to <code>docker.sock</code> considered dangerous?</summary>

Whoever can talk to it can start privileged containers and mount the host's filesystem: effectively root on the host.
</details>

<details><summary><b>C9.</b> What does <code>docker run nginx</code> expand <code>nginx</code> to?</summary>

`docker.io/library/nginx:latest`: the Docker Hub registry, the official `library` namespace, repository `nginx`, tag `latest`.
</details>

<details><summary><b>C10.</b> What does Kubernetes use from this stack?</summary>

containerd (or CRI-O) and runc, plus the same OCI images. Kubernetes talks to the runtime through the CRI; it doesn't need dockerd.
</details>

---

## Part D: VM vs containers (5)

<details><summary><b>D1.</b> Using the houses and apartments analogy, what is the "shared foundation"?</summary>

The host's Linux kernel, which every container shares.
</details>

<details><summary><b>D2.</b> Give two advantages of VMs over containers.</summary>

Stronger isolation (separate kernels, a hypervisor boundary), and the ability to run different operating systems or kernels on the same hardware.
</details>

<details><summary><b>D3.</b> Give two advantages of containers over VMs.</summary>

Much smaller (MBs, not GBs) and faster to start (seconds, not minutes). Plus higher density, and easy, consistent packaging with images.
</details>

<details><summary><b>D4.</b> Do containers and VMs compete, or can they work together?</summary>

They work together. Cloud containers typically run inside VMs, and Docker Desktop on Mac and Windows runs containers in a Linux VM.
</details>

<details><summary><b>D5.</b> A container image is labelled "Ubuntu". Does it contain the Ubuntu kernel?</summary>

No. It contains Ubuntu's userland files (shell, libraries, apt). It runs on the host's kernel.
</details>

---

## Part E: Troubleshooting (5)

<details><summary><b>E1.</b> "Cannot connect to the Docker daemon at unix:///var/run/docker.sock." What's wrong, and what's your first fix?</summary>

The CLI works, but the daemon isn't running or reachable. Start Docker Desktop (or `sudo systemctl start docker`), then check with `docker version`: you should see a `Server:` section.
</details>

<details><summary><b>E2.</b> <code>docker run -d myapp</code> returns an ID, but <code>docker ps</code> is empty. What do you check?</summary>

`docker ps -a` for the exit code, then `docker logs <name>`. The main process exited (wrong command, missing file, or a crash), so the container stopped.
</details>

<details><summary><b>E3.</b> A container keeps exiting with code 137. What are the likely causes, and how do you confirm?</summary>

SIGKILL: most often an out-of-memory kill from its cgroup limit. Confirm with `docker inspect <name> --format '{{.State.OOMKilled}}'`. Otherwise someone ran `docker kill`, or a stop timed out.
</details>

<details><summary><b>E4.</b> <code>docker pull myteam/app:2.0</code> says "pull access denied … may require docker login". Two possible causes?</summary>

The repository is private and you aren't logged in (`docker login`), or there's a typo in the name or tag, so it doesn't exist.
</details>

<details><summary><b>E5.</b> You changed a file inside a container, restarted it with <code>docker restart</code>, and the change is still there. But after <code>docker rm</code> and <code>docker run</code> it's gone. Why the difference?</summary>

`restart` keeps the same container, including its writable layer. `rm` deletes that layer, and `run` creates a new container fresh from the image.
</details>

---

### 🏆 Bonus
Explain to someone, **without notes**, why the industry moved from physical servers → VMs → containers, in under two minutes. If you can, you've truly understood D00. 🎉

⬅️ [Back to D00](README.md) · ➡️ [D01: First Steps](../01-first-steps/README.md)
