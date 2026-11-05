# Lab D01: First Steps, and the Image Arcade 🕹️

> ⏱ 30 min · 🟢 Absolute beginner · Needs: Docker installed ([setup](../../00-setup/README.md))

## 🎯 What you'll learn
- Check that Docker is installed and working
- The Docker **client** vs the Docker **engine**
- What *really* happens when you type `docker run`
- That a 3-second command can give you a video game, a web server, or an aquarium, and **why that changes everything**

## 🧠 Concept in 60 seconds

```
  You ──▶ docker CLI (client) ──API──▶ Docker Engine (daemon) ──▶ containers
                                             │
                                             └── pulls images from ──▶ Registry (Docker Hub)
```

- **Image** = a sealed box containing an app **and everything it needs** (OS files, libraries, config).
- **Container** = that box, opened and running.
- **Registry** = an app store for boxes (Docker Hub has millions).

> 🎤 *The promise:* "It works on my machine" becomes "It works on **every** machine", because the machine travels inside the box.

## 🧪 Hands-on

### Step 1: Is Docker here?
```bash
docker --version
docker version          # look for TWO sections: Client and Server
```
> ❗ `Cannot connect to the Docker daemon` means the **client** works but the **engine** isn't running. Start Docker Desktop and wait for the whale to stop animating. This is the #1 day-one problem.

### Step 2: Ask the engine about itself
```bash
docker info --format 'Engine {{.ServerVersion}} on {{.OperatingSystem}} · {{.NCPU}} CPUs · {{.MemTotal}} bytes RAM'
```

### Step 3: Your first container
```bash
docker run hello-world
```
Read the output. Docker just did four things: **contacted** the engine → **pulled** the image → **created** a container → **streamed** its output to you. Run it again: no download this time, because the image is cached.

---

## 🕹️ The Image Arcade
Every one of these is **one command**. Nothing to install, nothing to configure, and nothing left behind (`--rm`).

### 🍄 1. A full video game, from the internet, in your browser
```bash
docker run -d --rm --name mario -p 8600:8080 pengbai/docker-supermario
```
Wait ~20 seconds, then open **http://localhost:8600**. Arrow keys to move, `A`/`S` to jump and run. 🎮

🔍 You didn't install Java, Tomcat, or a game. Someone packaged **all of it** into an image, and it ran on your laptop exactly as it ran on theirs.
```bash
docker images pengbai/docker-supermario     # ~1 GB! Remember this number for Lab D05 😉
docker stop mario
```
> 🍎 On Apple Silicon you may see a *platform (linux/amd64) does not match* warning. Docker is **emulating an Intel CPU** to run it. That's containers plus emulation, and it's still one command.

### 🌈 2. Terminal toys
```bash
docker run --rm -it wernight/funbox nyancat              # Ctrl+C to stop
docker run --rm -it wernight/funbox asciiquarium         # Ctrl+C to stop
docker run --rm -it wernight/funbox cmatrix              # Ctrl+C: you're in the Matrix
docker run --rm -it wernight/funbox sl                   # typo "ls" as "sl" and a train runs you over
docker run --rm wernight/funbox sh -c 'cowsay "I live in a container" | lolcat -f'
```
🔍 Each run starts a **brand-new** container, and `--rm` deletes it the moment it exits. Containers are **disposable**.

### 🐳 3. Docker's own welcome page
```bash
docker run -d --rm --name welcome -p 8088:80 docker/welcome-to-docker
```
Open **http://localhost:8088**, then `docker stop welcome`.

### 🌐 4. A web server that tells you who it is
```bash
docker run -d --rm --name hello -p 8089:80 nginxdemos/hello
```
Open **http://localhost:8089**. It shows the container's **name and IP**. Refresh: same container. Later (Labs D08 and K05), the same kind of page will show you *different* containers answering: that's load balancing.
```bash
docker stop hello
```

### 🪦 5. A lesson from a dead whale
Old tutorials all start with this:
```bash
docker run docker/whalesay cowsay hello
```
💥 It fails: `media type ... manifest.v1+prettyjws is no longer supported`. The image was built in 2015 in a format modern Docker no longer reads.
> 🏭 **Production lesson #1:** images age. Unmaintained base images break, collect vulnerabilities, and eventually stop working. Rebuild regularly, from maintained images.

---

### Step 4: What did we leave behind?
```bash
docker ps             # running containers: probably none (we used --rm)
docker ps -a          # ALL containers: the hello-world ones are still there, stopped
docker images         # every image you pulled is cached locally
```

### Step 5: Help, the skill that never expires
```bash
docker --help
docker run --help | head -40
```

## 🏭 In production
- CI servers run `docker version` / `docker info` first, to fail fast when a build machine is broken.
- Servers don't use Docker Desktop. They run **Docker Engine** or **containerd** on Linux. Kubernetes nodes run containerd, and your images run there unchanged, because images follow an open standard (OCI).

## 🏆 Challenge
1. Run Mario on port **9999** instead. Which number in `-p` did you change, and why?
2. Run **two** Marios at once on different ports. Are they sharing a game?
3. Find the size of every image you pulled today: `docker images --format '{{.Repository}}:{{.Tag}} → {{.Size}}'`

## ✅ Checkpoint
<details><summary>1. "Cannot connect to the Docker daemon". Is Docker installed?</summary>

The client is (it printed the error). The **engine** isn't running.
</details>
<details><summary>2. Why was the second <code>hello-world</code> instant?</summary>

The image was cached locally, so there was nothing to download.
</details>
<details><summary>3. In one sentence, image vs container?</summary>

An image is the sealed, read-only package; a container is a running instance of it. One image can start many containers.
</details>

## 🧹 Cleanup
```bash
docker rm -f mario welcome hello 2>/dev/null; docker container prune -f
```

➡️ Next: [D02: Images & the Container Lifecycle](../02-images-containers-lifecycle/README.md)
