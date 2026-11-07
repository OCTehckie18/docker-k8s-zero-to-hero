# Lab D01: First Steps, and the Image Arcade 🕹️

> ⏱ 30–60 min (the arcade is pick-and-choose) · 🟢 Absolute beginner · Needs: Docker installed ([setup](../../00-setup/README.md))
>
> 🧭 New to containers? Do **[D00 Docker Foundations](../00-foundations/README.md)** first: it explains *why* everything in this lab works.

## 🎯 What you'll learn
- Check that Docker is installed and working
- The Docker **client** vs the Docker **engine**
- What *really* happens when you type `docker run`
- That a 3-second command can give you a video game, a web server, or an aquarium, and **why that changes everything**
- How to get **VS Code, Jupyter, a whiteboard and a PDF toolkit** running in one command each, and remove them without a trace

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
Every one of these is **one command**. Nothing to install, nothing to configure, and nothing left behind (`--rm`). Pick what you like: you don't need to do them all.

| # | Stall | Why you'll love it | Download |
|---|---|---|---|
| 1 | 🍄 [Mario in your browser](#-1-a-full-video-game-from-the-internet-in-your-browser) | a whole game, zero installs | ~1 GB |
| 2 | 🌈 [Terminal toys](#-2-terminal-toys) | rainbow cats, fish, a train | ~200 MB |
| 3 | 🌍 [Ask the internet from a 10 MB box](#-3-ask-the-internet-from-a-10-mb-box) | Bengaluru weather, QR codes, instant command help | 10 MB |
| 4 | 🎓 [Student survival kit](#-4-the-student-survival-kit-real-apps-one-command-each) | VS Code, Jupyter, whiteboard, dev tools, PDF toolkit | 25 MB – 1 GB each |
| 5 | 🐳 [Docker's welcome page](#-5-dockers-own-welcome-page) | your first web page from a container | small |
| 6 | 🌐 [A server that says who it is](#-6-a-web-server-that-tells-you-who-it-is) | meet load balancing (later) | small |
| 7 | 🪦 [A dead whale](#-7-a-lesson-from-a-dead-whale) | why images get old | fails, on purpose |

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
One image, `wernight/funbox`, packs a box of silly terminal programs. The word **after** the image name picks which program runs inside the container. Try them one at a time:

| Run this | What you'll see | How it ends |
|---|---|---|
| `docker run --rm -it wernight/funbox nyancat` | 🐱🌈 a rainbow cat flying across your terminal | press **Ctrl+C** |
| `docker run --rm -it wernight/funbox asciiquarium` | 🐠 an aquarium of fish, sharks and bubbles | press **Ctrl+C** |
| `docker run --rm -it wernight/funbox cmatrix` | 💚 green "Matrix" code raining down | press **Ctrl+C** |
| `docker run --rm -it wernight/funbox sl` | 🚂 a steam train drives across the screen, right to left | ends **by itself** after a few seconds |
| `docker run --rm wernight/funbox sh -c 'cowsay "I live in a container" \| lolcat -f'` | 🐮 a rainbow cow saying hello | ends by itself |

> 🍎 **Apple Silicon (M1/M2/M3/M4)?** You'll see `WARNING: The requested image's platform (linux/amd64) does not match…`. That's fine: this image was built for Intel CPUs, so Docker **emulates** one. To silence it, add `--platform linux/amd64`, e.g. `docker run --rm -it --platform linux/amd64 wernight/funbox sl`.

<details><summary>🚂 Why a train? (the <code>sl</code> joke, and a cool trick with <code>ls</code>)</summary>

`ls` is the command that **lists files**. People type it so often that they constantly mistype it as **`sl`**. Someone wrote a joke program called `sl` (**S**team **L**ocomotive) that punishes the typo: instead of a file list, a train rolls across your screen and you have to wait for it. 😄

When the train is gone, your terminal looks exactly as before. That's normal: `sl` cleans up after itself.

Now type the command **correctly**, `ls`, and look closely at what it lists:
```bash
docker run --rm wernight/funbox ls /
```
```
bin  boot  dev  etc  examples  home  lib  lib64  media  menu.sh  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```
🤯 These are **not** the files on your laptop. You're seeing the inside of the container: its own little Linux file system, which came from the image. Your project folder isn't there at all. That's **isolation** you can see with your own eyes (you'll learn how it works in [D00 §7](../00-foundations/README.md#7-inside-a-container-namespaces-cgroups-and-layers)).
</details>

🔍 Each run starts a **brand-new** container, and `--rm` deletes it the moment it exits. Containers are **disposable**.

### 🌍 3. Ask the internet from a 10 MB box
`curlimages/curl` is a **tiny** container (about 10 MB) whose only job is to fetch web pages. Some websites answer in pure text art, made for terminals:

| Run this | What you get |
|---|---|
| `docker run --rm curlimages/curl:8.11.1 -s "wttr.in/Bengaluru?0"` | ☁️ today's **Bengaluru weather**, drawn in your terminal (try your home town!) |
| `docker run --rm curlimages/curl:8.11.1 -s "wttr.in/Moon"` | 🌙 tonight's **moon phase** |
| `docker run --rm curlimages/curl:8.11.1 -s qrenco.de/https://github.com/vellankikoti`  | 🔳 a **scannable QR code** of your GitHub (scan it with your phone!) |
| `docker run --rm curlimages/curl:8.11.1 -s qrenco.de/https://www.linkedin.com/in/vellankikoti/`  | 🔳 a **scannable QR code** of your LinkedIn (scan it with your phone!) |
| `docker run --rm curlimages/curl:8.11.1 -s "cheat.sh/tar?T"` | 📖 **instant help** for any command, with real examples: try `git`, `docker`, `chmod`, `ssh` |

> 💡 Bookmark that last one. `cheat.sh/<command>` saves you in every lab, viva and interview prep.

🔍 The container lived for about one second: it started, fetched one page, printed it and vanished. Many real containers work exactly like this: **one job, then exit**.

### 🎓 4. The student survival kit: real apps, one command each
Fun is good. **Useful** is better. These are real tools that students install, break and reinstall all the time. With Docker you install **nothing**: run it, use it, stop it, and your laptop is exactly as it was.

#### 💻 a. VS Code in your browser
```bash
docker run -d --rm --name vscode -p 127.0.0.1:8090:8080 -v "$PWD:/home/coder/project" codercom/code-server:latest --auth none
```
Open **http://localhost:8090**, then **File → Open Folder → `/home/coder/project`**. That's **your current folder**, editable from a full VS Code running inside a container. 🤯
- `-v "$PWD:/home/coder/project"` shares your folder with the container (you'll master this in [Lab D06](../06-volumes/README.md)). Your files stay on your laptop, so they're safe when the container is gone.
- 🔐 `--auth none` turns off the password, so we bind to **`127.0.0.1`** only: nobody else on the college Wi-Fi can open it. **Always** do this for tools without a password.

```bash
docker stop vscode
```

#### 📓 b. Jupyter Lab, for your Python / data science / ML classes
```bash
docker run -d --rm --name jupyter -p 127.0.0.1:8888:8888 -v "$PWD:/home/jovyan/work" quay.io/jupyter/base-notebook:latest
docker logs jupyter 2>&1 | grep -m1 "127.0.0.1:8888"     # copy this link (it includes your login token)
```
Open that link, create a notebook inside **`work/`**, and type `print("Hello from a container!")`. No Python install, no "pip broke my laptop", no version fights between subjects. Notebooks you save in `work/` appear in your folder.
```bash
docker stop jupyter
```

#### 🎨 c. Excalidraw: a whiteboard for group projects and exam diagrams
```bash
docker run -d --rm --name whiteboard -p 8091:80 excalidraw/excalidraw:latest
```
Open **http://localhost:8091** and sketch: architecture diagrams, flowcharts, mind maps. Export as PNG or SVG straight into your report. Then `docker stop whiteboard`.

#### 🧰 d. IT-Tools: 80+ handy tools in one 25 MB box
```bash
docker run -d --rm --name tools -p 8092:80 corentinth/it-tools:latest
```
Open **http://localhost:8092**. A JSON formatter, a password generator, a QR code maker, Base64, hash, UUID, Unix-time and unit converters… everything you usually google "online converter" for, running **privately on your laptop**. Then `docker stop tools`.

#### 📄 e. Bonus: Stirling-PDF, a PDF toolkit for assignments (big download: ~1 GB, do it on good Wi-Fi)
```bash
docker run -d --rm --name pdf -p 8093:8080 stirlingtools/stirling-pdf:latest
```
Wait ~30 seconds, then open **http://localhost:8093**: **merge** your assignment PDFs, **compress** them under the upload limit, convert Word or images to PDF, add page numbers, rotate, split… 🔒 Your documents **never leave your laptop**, unlike random "free PDF" websites. Then `docker stop pdf`.

> 🎯 **The big idea:** you just "installed" five real applications in minutes, and **uninstalled them perfectly** with `docker stop` and `docker rmi`: no leftover files, no broken settings. This is why developers love Docker: **try anything, risk nothing**.

### 🐳 5. Docker's own welcome page
```bash
docker run -d --rm --name welcome -p 8088:80 docker/welcome-to-docker
```
Open **http://localhost:8088**, then `docker stop welcome`.

### 🌐 6. A web server that tells you who it is
```bash
docker run -d --rm --name hello -p 8089:80 nginxdemos/hello
```
Open **http://localhost:8089**. It shows the container's **name and IP**. Refresh: same container. Later (Labs D08 and K05), the same kind of page will show you *different* containers answering: that's load balancing.
```bash
docker stop hello
```

### 🪦 7. A lesson from a dead whale
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
4. Run VS Code **and** Jupyter at the same time, both pointed at the same folder. Create a file in one: does it appear in the other? Why?
5. Generate a QR code that opens **this** repo, and scan it with your phone.

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
<details><summary>4. You "installed" VS Code and Jupyter today. How do you uninstall them completely?</summary>

`docker stop` the containers (with `--rm` they're deleted automatically), then `docker rmi` the images. Nothing was installed on your laptop itself; the only thing left is your own files in your folder, which is exactly what you want.
</details>

## 🧹 Cleanup
```bash
docker rm -f mario welcome hello vscode jupyter whiteboard tools pdf 2>/dev/null; docker container prune -f
```
Free up disk space too (the student kit images are big):
```bash
docker rmi codercom/code-server:latest quay.io/jupyter/base-notebook:latest excalidraw/excalidraw:latest corentinth/it-tools:latest stirlingtools/stirling-pdf:latest 2>/dev/null
```

➡️ Next: [D02: Images & the Container Lifecycle](../02-images-containers-lifecycle/README.md)
