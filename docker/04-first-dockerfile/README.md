# Lab D04: Your First Dockerfile: Package the Showdown Yourself

> ⏱ 45 min · 🟢 Beginner

## 🎯 What you'll learn
- Write a Dockerfile from scratch, one instruction at a time
- `docker build`, the build context, tags, and the layer cache
- Configure **one image** into **many different apps** with environment variables
- `CMD` vs `ENTRYPOINT`

## 🧠 Concept in 60 seconds
A **Dockerfile** is a recipe. Each instruction adds a **layer**; the layers stack up into an image.
```dockerfile
FROM python:3.12-alpine     # start from someone else's image (OS + Python)
WORKDIR /app                # cd /app (created if missing)
COPY . .                    # put our code in
CMD ["python", "app.py"]    # what to run when a container starts
```
`docker build -t NAME:TAG FOLDER` sends the **folder (the "build context")** to the engine, which follows the recipe.

## 🧪 Hands-on
The app lives in [`apps/api/`](../../apps/api/): `app.py` (Python standard library only, no pip install) and `static/index.html` (the UI). Skim `app.py`. It reads everything from **environment variables**, logs to **stdout**, and exposes **health endpoints**. Those are the three habits of a container-friendly app.

### Step 1: The smallest Dockerfile that works
[`Dockerfile.v1`](Dockerfile.v1):
```dockerfile
FROM python:3.12-alpine
WORKDIR /app
COPY . .
CMD ["python", "app.py"]
```
Build and run it, from the **repository root**:
```bash
docker build -f docker/04-first-dockerfile/Dockerfile.v1 -t z2h/api:v1 apps/api
docker run -d --name v1 -p 8080:8080 z2h/api:v1
```
Open http://localhost:8080. **You just packaged an application.** 🎉

### Step 2: The layer cache
Build again and notice `CACHED` on every step: nothing changed, so nothing is rebuilt.
Now change something. Open `apps/api/static/index.html`, find `z2h showdown` in the footer, and add your name. Rebuild:
```bash
docker build -f docker/04-first-dockerfile/Dockerfile.v1 -t z2h/api:v1 apps/api
docker rm -f v1 && docker run -d --name v1 -p 8080:8080 z2h/api:v1
```
Refresh the page and look for your name in the footer. Only the steps **after** the changed file re-ran. *(Undo your edit afterwards.)*

### Step 3: 🎩 One image, infinite apps
Configuration comes from **outside** the image:
```bash
docker run -d --name food   -p 8081:8080 -e TITLE="The Great Food Fight" \
  -e VOTE_OPTIONS="pizza:🍕:Pizza,burger:🍔:Burger,tacos:🌮:Tacos" -e THEME_COLOR="#ffb400" z2h/api:v1

docker run -d --name ide    -p 8082:8080 -e TITLE="Editor Wars" \
  -e VOTE_OPTIONS="vim:🟢:Vim,vscode:🔵:VS Code,emacs:🟣:Emacs" -e THEME_COLOR="#4f8cff" z2h/api:v1

docker run -d --name season -p 8083:8080 -e TITLE="Best Season" \
  -e VOTE_OPTIONS="summer:☀️:Summer,monsoon:🌧️:Monsoon,winter:❄️:Winter" -e THEME_COLOR="#2fd47a" z2h/api:v1
```
Open :8081, :8082, :8083 side by side. **Same image, three different apps.** This is exactly how one image moves from dev → staging → production with different settings.

From a file instead:
```bash
printf 'TITLE=Team Lunch\nVOTE_OPTIONS=biryani:🍛:Biryani,dosa:🥞:Dosa\n' > /tmp/lunch.env
docker run -d --name lunch -p 8084:8080 --env-file /tmp/lunch.env z2h/api:v1
```

### Step 4: CMD vs ENTRYPOINT
```bash
docker run --rm z2h/api:v1 python --version                       # anything after the image name replaces CMD
docker run --rm z2h/api:v1 python -c "print('I replaced CMD')"
```
[`Dockerfile.entrypoint`](Dockerfile.entrypoint) makes the image *be* a program, with `CMD` as default arguments:
```bash
docker build -f docker/04-first-dockerfile/Dockerfile.entrypoint -t z2h/pyrun apps/api
docker run --rm z2h/pyrun                         # python -c "print('default args')"
docker run --rm z2h/pyrun -c "print(6 * 7)"       # python -c "print(6 * 7)"
```
| | Purpose | Override with |
|---|---|---|
| `ENTRYPOINT` | the executable | `--entrypoint` |
| `CMD` | default command, or default args to ENTRYPOINT | args after the image name |

### Step 5: Compare with the production Dockerfile
Open [`apps/api/Dockerfile`](../../apps/api/Dockerfile). It adds a **non-root user**, a **HEALTHCHECK**, `EXPOSE`, environment defaults, and a [`.dockerignore`](../../apps/api/.dockerignore).
```bash
docker build -t z2h/api:1.0 apps/api
docker run --rm z2h/api:v1  id      # uid=0(root)  😬
docker run --rm z2h/api:1.0 id      # uid=10001    ✅
docker images z2h/api
```

## 🏭 In production
- Images are built by **CI from a Git commit**, not on laptops.
- Tag with something traceable (`1.4.2`, or the Git SHA `3f9c2ab`). `latest` tells you nothing.
- Config lives outside the image (env vars, ConfigMaps, Secrets). **Build once, deploy everywhere.**

## 🏆 Challenge
Create your own poll for your class (`TITLE`, three options, your own colour) and get the room to vote on it from their phones.

## ✅ Checkpoint
<details><summary>1. Does <code>EXPOSE 8080</code> make the app reachable?</summary>

No. It's documentation. Only `-p` publishes a port.
</details>
<details><summary>2. Why do the Food Fight and Editor Wars apps need no rebuild?</summary>

All app-specific values come from environment variables at runtime; the image itself is generic.
</details>

## 🧹 Cleanup
```bash
docker rm -f v1 food ide season lunch 2>/dev/null; docker rmi z2h/pyrun z2h/api:v1 2>/dev/null; rm -f /tmp/lunch.env
```

➡️ Next: [D05: Production-Grade Dockerfiles](../05-production-dockerfiles/README.md)
