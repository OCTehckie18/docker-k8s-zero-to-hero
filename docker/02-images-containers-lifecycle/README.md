# Lab D02: Images & the Container Lifecycle

> ⏱ 40 min · 🟢 Beginner

## 🎯 What you'll learn
- Image vs container, explained in practical terms
- Image names: `registry/repository:tag` and digests
- The container lifecycle: created → running → stopped → removed
- **Why a container stops when its main process exits.** This is the #1 beginner surprise.

## 🧠 Concept in 60 seconds

| | Image | Container |
|---|---|---|
| What | A read-only **template**: app + dependencies + filesystem | A **running instance** of an image |
| Analogy | A class / a recipe | An object / a cooked meal |
| Created by | `docker build` / `docker pull` | `docker run` / `docker create` |
| Changes? | Never. Images are immutable | Has a thin writable layer, lost when removed |

```
created ──start──▶ running ──(main process exits / docker stop)──▶ exited ──docker rm──▶ gone
                     │  ▲
               pause │  │ unpause
                     ▼  │
                    paused
```

> **Golden rule:** a container lives exactly as long as its **main process (PID 1)** lives.

## 🧪 Hands-on

### Part A: Images

```bash
docker pull nginx:1.27-alpine
docker pull nginx            # no tag means ":latest"
docker images nginx
```
🔍 Compare the sizes. `alpine` variants are much smaller. Smaller images pull faster, start faster, and contain fewer vulnerabilities.

Anatomy of an image reference:
```
docker.io/library/nginx:1.27-alpine
└──┬────┘ └──┬──┘ └─┬─┘ └────┬────┘
registry  namespace repo     tag
```
```bash
docker image inspect nginx:1.27-alpine --format '{{.Id}}'
docker image inspect nginx:1.27-alpine --format '{{.RepoDigests}}'
docker image history nginx:1.27-alpine          # the layers that make up the image
```
🔍 A **tag** (`1.27-alpine`) is a movable label: the publisher can point it at a new build tomorrow. A **digest** (`sha256:...`) is a content fingerprint and never changes. Production systems often pin digests.

### Part B: The lifecycle, step by step

```bash
docker create --name web nginx:1.27-alpine     # created, not started
docker ps -a --filter name=web                 # STATUS: Created

docker start web                               # running
docker ps --filter name=web                    # STATUS: Up X seconds

docker pause web && docker ps --filter name=web     # (Paused)
docker unpause web

docker stop web                                # sends SIGTERM, then SIGKILL after 10s
docker ps -a --filter name=web                 # STATUS: Exited (0)

docker start web                               # same container, starts again
docker rm -f web                               # force-remove (stop + rm)
```
`docker run` = `docker create` + `docker start` (+ attach to output).

### Part C: Why does my container exit immediately? 🤔

```bash
docker run --name short ubuntu:24.04
docker ps -a --filter name=short
```
It exited instantly with code 0. The default command of `ubuntu` is `bash`. With no terminal attached, bash has nothing to read, so it exits. **PID 1 exited, so the container stopped.**

Now keep the main process alive:
```bash
docker run -d --name longer ubuntu:24.04 sleep 300
docker ps --filter name=longer        # Up
```
And give bash an interactive terminal:
```bash
docker run -it --rm ubuntu:24.04 bash
# you are now INSIDE the container
cat /etc/os-release
ps aux            # look: bash is PID 1
exit              # PID 1 exits, so the container stops (and --rm deletes it)
```

Flags you just used:
| Flag | Meaning |
|---|---|
| `-d` | detached: run in background |
| `-i` | keep STDIN open (interactive) |
| `-t` | allocate a terminal (TTY) |
| `--rm` | delete the container automatically when it stops |
| `--name` | give it a human name instead of a random one |

### Part D: Exit codes tell a story

```bash
docker run --name ok     busybox sh -c 'exit 0'
docker run --name failed busybox sh -c 'echo boom >&2; exit 3'
docker ps -a --filter name=ok --filter name=failed --format 'table {{.Names}}\t{{.Status}}'
docker inspect failed --format 'exit={{.State.ExitCode}} error={{.State.Error}}'
docker logs failed
```
| Exit code | Usually means |
|---|---|
| 0 | finished successfully |
| 1, 2, 3… | the application reported an error |
| 125 | `docker run` itself failed (bad flag, etc.) |
| 126 / 127 | command not executable / not found |
| 137 | killed by SIGKILL (often **out of memory** or `docker kill`) |
| 143 | stopped by SIGTERM (normal `docker stop`) |

### Part E: Containers are isolated and disposable

```bash
docker run -d --name c1 busybox sleep 600
docker exec c1 sh -c 'echo "I live in c1" > /tmp/note.txt'
docker run --rm busybox cat /tmp/note.txt     # different container: file not found
docker exec c1 cat /tmp/note.txt              # still there in c1
docker rm -f c1                               # container removed, and the file is gone forever
```
🔍 Each container gets its **own writable layer** on top of the shared read-only image. When you remove the container, the layer and your file go with it. Lab D06 shows how to keep data.

## 🏭 In production
- **Never use `:latest` in production.** You can't tell what version is running, and rollbacks become guesswork. Use explicit versions (`nginx:1.27.3-alpine`) or digests.
- **Treat containers as cattle, not pets.** You don't fix a broken container by hand; you replace it with a new one from a fixed image. Kubernetes is built on this idea.
- Exit code **137** in production almost always triggers the question "was it OOM-killed?" (see Lab D11).

## 🏆 Challenge
1. Run `docker run -d --name web2 nginx:1.27-alpine` and stop it with `docker stop`. What exit code do you get, and why is it 0 and not 143? (Hint: nginx handles SIGTERM gracefully.)
2. Find all images on your machine larger than 100MB. (Hint: `docker images --format '{{.Repository}}:{{.Tag}} {{.Size}}'`)
3. Make a container that prints the date every 2 seconds forever. Then stop it.

## ✅ Checkpoint
<details><summary>1. A container shows "Exited (0)" a second after starting. Is something broken?</summary>

Not necessarily. Its main process finished successfully. If you expected a long-running service, the command is wrong. For example, it ran a script that ended instead of a server that keeps running.
</details>
<details><summary>2. What is the difference between <code>docker stop</code> and <code>docker kill</code>?</summary>

`stop` sends SIGTERM and waits (10s default) for graceful shutdown before SIGKILL. `kill` sends SIGKILL immediately, so the app has no chance to finish in-flight requests.
</details>
<details><summary>3. Two containers from the same image: do they share files?</summary>

They share the read-only image layers, but each has its own writable layer. Changes in one are invisible to the other.
</details>

## 🧹 Cleanup
```bash
docker rm -f web short longer ok failed web2 2>/dev/null; docker container prune -f
```

➡️ Next: [D03: Working Inside Containers](../03-inside-containers/README.md)
