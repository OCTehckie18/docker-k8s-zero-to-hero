# Lab D05: Production-Grade Dockerfiles

> ⏱ 60 min · 🟡 Intermediate

## 🎯 What you'll learn
- Spot the classic Dockerfile anti-patterns
- **Layer caching**: order instructions to build in seconds, not minutes
- **Multi-stage builds**: ship a ~13MB image instead of ~1.3GB
- **PID 1 & signals**: why some containers take 10 seconds to stop
- Non-root users, `.dockerignore`, and scanning images for vulnerabilities

## 🧪 Hands-on

### Part A: Find the problems 🔍
Open [`bad/Dockerfile`](bad/Dockerfile):
```dockerfile
FROM python:latest
COPY . /app
WORKDIR /app
RUN apt-get update
RUN apt-get install -y curl vim
ENV API_KEY=sk-live-1234567890
CMD ./start.sh
```
Try to find at least six problems before you open the answer.

<details><summary>Answer: the problems</summary>

| # | Problem | Why it hurts | Fix |
|---|---|---|---|
| 1 | `python:latest` | unpinned: builds change silently; huge Debian image (~1GB) | `python:3.12-alpine` or `-slim`, pinned |
| 2 | `COPY . /app` before installing packages | any code change invalidates the cache for every later step | copy dependency files first, code last |
| 3 | no `.dockerignore` | `.git`, `.env`, and local junk end up in the image | add `.dockerignore` |
| 4 | `apt-get update` and `install` in separate `RUN`s | stale package index cached forever; extra layers | one `RUN` with `&& rm -rf /var/lib/apt/lists/*` |
| 5 | `vim`, `curl` in a runtime image | larger attack surface, more CVEs | install only what the app needs at runtime |
| 6 | secret in `ENV` | **anyone who can pull the image can read it** (`docker inspect`, `docker history`) | inject secrets at runtime (Lab D08, K07) |
| 7 | runs as root | a container breakout gives an attacker root | `USER 10001` |
| 8 | shell-form `CMD` + script without `exec` | app is not PID 1, never gets SIGTERM, so it is killed after 10s | exec-form `CMD [...]` and `exec` in scripts |
</details>

Prove #6 yourself:
```bash
docker build -t z2h/bad docker/05-production-dockerfiles/bad
docker history --no-trunc z2h/bad | grep API_KEY
docker inspect z2h/bad --format '{{json .Config.Env}}'
```
🔓 The "secret" is readable by anyone who has the image.

### Part B: PID 1 and graceful shutdown ⏱
```bash
docker run -d --name bad z2h/bad
time docker stop -t 10 bad    # ~10 seconds!
docker inspect bad --format 'exit code: {{.State.ExitCode}}'     # 137 = SIGKILL
docker rm bad

docker run -d --name good z2h/api:1.0
time docker stop -t 10 good   # under a second
docker inspect good --format 'exit code: {{.State.ExitCode}}'    # 0 = clean exit
docker rm good
```
🔍 **Why:** in the bad image, PID 1 is `/bin/sh` running `start.sh`. A shell running as PID 1 ignores SIGTERM and does not forward it to its child (`python`). Docker waits for the stop timeout (we passed `-t 10`; the engine default is usually 10s) and then sends SIGKILL. The app never gets a chance to finish requests or close database connections.

Fixes (use one):
- exec-form `CMD ["python", "app.py"]` so the app *is* PID 1
- in shell scripts, end with `exec python app.py` (the shell replaces itself with the app)
- run with `docker run --init` (adds a tiny init process that forwards signals)

> In Kubernetes this matters even more. Every rolling update stops pods, and a pod that ignores SIGTERM adds `terminationGracePeriodSeconds` (30s default) to every rollout and drops in-flight requests.

### Part C: Multi-stage builds 📦
```bash
cd docker/05-production-dockerfiles/go-app
docker build -f Dockerfile.single     -t z2h/go:single .
docker build -f Dockerfile.multistage -t z2h/go:multi  .
docker images z2h/go
cd -
```
Expected (approximate):
```
REPOSITORY  TAG     SIZE
z2h/go      single  ~1.3GB
z2h/go      multi   ~13MB
```
Same program, about 100× smaller. Read [`Dockerfile.multistage`](go-app/Dockerfile.multistage):
- Stage `build` has the compiler and the source code.
- The final stage copies **only the binary** into `distroless/static`, which has no shell, no package manager, and runs as non-root.

```bash
docker run -d --name go -p 8080:8080 z2h/go:multi && sleep 1 && curl -s localhost:8080
docker exec go sh            # fails: there is no shell. That is a security feature.
docker rm -f go
```

### Part D: Layer caching 🚀
The rule: **put what changes least at the top and what changes most at the bottom.**

```dockerfile
# ❌ slow: every code change re-installs all dependencies
COPY . .
RUN pip install -r requirements.txt

# ✅ fast: dependencies are re-installed only when requirements.txt changes
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```
See it happen with the Go app. Edit the message in `main.go`, then rebuild:
```bash
docker build -f docker/05-production-dockerfiles/go-app/Dockerfile.multistage -t z2h/go:multi docker/05-production-dockerfiles/go-app
```
`go mod download` shows `CACHED`; only the code steps re-run.

### Part E: Scan for vulnerabilities 🛡
Use either tool, whichever is installed:
```bash
docker scout quickview z2h/bad            # built into Docker Desktop
# or
trivy image --severity HIGH,CRITICAL z2h/bad
trivy image --severity HIGH,CRITICAL z2h/go:multi
```
Compare the counts. The big `python:latest` image usually has dozens to hundreds of known CVEs; distroless usually has close to zero.

## ✅ Production Dockerfile checklist
- [ ] Base image pinned to a version (or digest), as small as practical (`-alpine`, `-slim`, distroless)
- [ ] Multi-stage build for compiled languages
- [ ] Dependency manifests copied before source code (cache-friendly)
- [ ] `.dockerignore` excludes `.git`, `.env`, tests, and build output
- [ ] No secrets in `ENV`, `ARG`, or copied files
- [ ] `USER` set to a non-root UID
- [ ] Exec-form `CMD`/`ENTRYPOINT`; scripts use `exec`
- [ ] App logs to stdout/stderr and handles SIGTERM
- [ ] `HEALTHCHECK` (Docker) or probes (Kubernetes)
- [ ] Image scanned in CI; build fails on critical CVEs

## 🏆 Challenge
Rewrite `bad/Dockerfile` so it passes every item on the checklist. Prove it by measuring `time docker stop` and the image size before and after.

## 🧹 Cleanup
```bash
docker rm -f bad good go 2>/dev/null; docker rmi z2h/bad z2h/go:single z2h/go:multi 2>/dev/null
```

➡️ Next: [D06: Volumes & Persistent Data](../06-volumes/README.md)
