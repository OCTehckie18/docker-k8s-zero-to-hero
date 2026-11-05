# Lab D09: Health Checks & Restart Policies

> ⏱ 35 min · 🟡 Intermediate

## 🎯 What you'll learn
- Why **"running" is not the same as "healthy"**
- Write and debug a `HEALTHCHECK`
- Restart policies: `no`, `on-failure`, `always`, `unless-stopped`
- Recognise a crash loop

## 🧠 Concept in 60 seconds
Docker knows whether a **process** is alive. It does not know whether your **app** works. A web server can be stuck, misconfigured, or cut off from its database while the process happily runs.

A **health check** is a command Docker runs inside the container periodically:
```
starting ──(check passes)──▶ healthy ──(N failures in a row)──▶ unhealthy
```
A **restart policy** decides what happens when the main process **exits**.

> ⚠️ Plain Docker does **not** restart *unhealthy* containers. It only reports them. Orchestrators like Kubernetes act on health (Lab K08).

## 🧪 Hands-on

### Step 1: Watch a health check in action
```bash
docker build -t z2h/api:1.0 apps/api     # from the repo root; the Dockerfile has a HEALTHCHECK
docker run -d --name h1 z2h/api:1.0
docker ps --filter name=h1               # (health: starting)
sleep 12; docker ps --filter name=h1     # (healthy)
docker inspect h1 --format '{{json .State.Health}}' | python3 -m json.tool | head -20
```

### Step 2: Running but broken
The app's `/readyz` checks Redis. Point it at a Redis that doesn't exist and use `/readyz` as the health check:
```bash
docker run -d --name h2 \
  -e REDIS_HOST=no-such-redis \
  --health-cmd 'wget -qO- http://127.0.0.1:8080/readyz || exit 1' \
  --health-interval 3s --health-retries 2 \
  z2h/api:1.0
sleep 10
docker ps --filter name=h2               # Up ... (unhealthy)
docker inspect h2 --format '{{range .State.Health.Log}}{{.ExitCode}} {{.Output}}{{end}}' | tail -3
```
🔍 STATUS says **Up**. Without the health check, nothing would tell you this container can't do its job.

### Step 3: Restart policies
```bash
# no restart (default): it crashes and stays dead
docker run -d --name r-no busybox sh -c 'echo started; sleep 2; exit 1'

# on-failure with a limit: retry up to 3 times on non-zero exit codes
docker run -d --name r-onfail --restart on-failure:3 busybox sh -c 'echo started; sleep 2; exit 1'

# always: restart no matter how it exited
docker run -d --name r-always --restart always busybox sh -c 'echo started; sleep 2; exit 0'

sleep 20
docker ps -a --filter name=r- --format 'table {{.Names}}\t{{.Status}}'
docker inspect r-onfail --format 'restarts={{.RestartCount}}'
docker inspect r-always --format 'restarts={{.RestartCount}}'
docker logs r-always            # "started" printed many times: a crash loop
```
| Policy | Restarts when | Typical use |
|---|---|---|
| `no` | never | one-off tasks, debugging |
| `on-failure[:N]` | exit code ≠ 0 | batch jobs that may fail transiently |
| `always` | always (also after daemon restart) | long-running services |
| `unless-stopped` | like `always`, except if *you* stopped it | long-running services (most common) |

### Step 4: 💥 Press the red button
```bash
docker run -d --name crashy --restart unless-stopped -p 8080:8080 z2h/api:1.0
```
Open http://localhost:8080, vote a few times, then hit **💥 Crash this server**. Watch the top bar flash red, then turn green again a second later: Docker restarted the container for you.
```bash
docker ps --filter name=crashy          # "Up 3 seconds" gives it away
docker inspect crashy --format 'restarts={{.RestartCount}}'
docker logs crashy | grep -E 'CRASH|listening'
```
😱 But look at the vote counter: **back to zero**. A restart is a new process, and in-memory state is gone. Self-healing doesn't save your data; only external storage does (D06, D08).

Now try the same with `--restart no` (the default). The app stays dead until a human notices. That's the difference between a 2-second blip and a 2 a.m. phone call.

## 🏭 In production
- Health checks should be **cheap and fast**. A check that runs a heavy database query every 5 seconds can itself cause an outage.
- Separate **liveness** ("am I stuck? restart me") from **readiness** ("can I take traffic right now?"). Kubernetes models these as separate probes. Mixing them up is a classic cause of cascading failures: if the database blips, every app instance restarts at once.
- Restart loops hide problems. Alert on restart counts, and always read the logs of the *previous* run.

## ✅ Checkpoint
<details><summary>1. A container is "unhealthy". Will Docker restart it?</summary>

No. Standalone Docker only reports health. (Swarm and Kubernetes act on it.) Restart policies react to the process *exiting*.
</details>
<details><summary>2. Why is it risky for a liveness-style check to depend on the database?</summary>

If the database has a short outage, every app instance fails its check and is restarted at the same moment. That turns a small blip into a full outage and a thundering herd on recovery.
</details>

## 🧹 Cleanup
```bash
docker rm -f h1 h2 r-no r-onfail r-always crashy 2>/dev/null
```

➡️ Next: [D10: Registries, Tags & Image Distribution](../10-registry-tags/README.md)
