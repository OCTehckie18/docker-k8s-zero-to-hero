# Lab D08: Docker Compose: the Whole Showdown in One Command

> ⏱ 50 min · 🟡 Intermediate

## 🎯 What you'll learn
- Describe a whole application stack in one file, [`compose.yaml`](compose.yaml)
- Start it, scale it, break it, and tear it down with single commands
- Start-up order that actually works (`depends_on` + health checks)
- Network segmentation, persistent volumes, and per-environment config

## 🧠 Concept in 60 seconds
Lab D07 took about eight long commands. Compose turns that into **one file** and **one command**. You describe **what** should exist; Compose makes it so.
```
                    ┌─ network: web ───────────────┐   ┌─ network: data ───────┐
 :8080 ──▶ frontend ──▶ api ×N ─────────────────────┼──▶│ api ──▶ redis          │
                    └──────────────────────────────┘   └────────┬──────────────┘
                                                            volume: redis-data
```
"Declare the desired state" is also the core idea of Kubernetes. You're already thinking like a platform engineer.

## 🧪 Hands-on
```bash
cd docker/08-compose
```

### Step 1: Read the file
Open [`compose.yaml`](compose.yaml). Can you answer these?
- Which service publishes a port?
- Why is `redis` only on the `data` network?
- What does `condition: service_healthy` add?

### Step 2: 🚀 Lift-off
```bash
docker compose up -d --build
docker compose ps                  # wait for "healthy"
```
Open **http://localhost:8080**. Share your laptop IP so the room can vote too (`ipconfig getifaddr en0` on macOS).

### Step 3: Everyday commands
```bash
docker compose logs -f api         # watch votes arrive live; Ctrl+C
docker compose exec api sh         # shell inside a service
docker compose top
docker compose config              # the final config after variables are substituted
```

### Step 4: 🔥 Scale to five
```bash
docker compose up -d --scale api=5
docker compose restart frontend     # nginx re-resolves "api" to all 5 containers
```
Watch the **Pod wall**: five coloured tiles light up as different containers answer. Every vote still lands in the same Redis, so the bars stay consistent.

Now try it **without** Redis to see why shared state matters:
```bash
docker run -d --name solo-1 --network showdown_web --network-alias solo z2h/api:1.0
docker run -d --name solo-2 --network showdown_web --network-alias solo z2h/api:1.0
for i in 1 2 3 4 5 6; do docker compose exec -T frontend wget -qO- "http://solo:8080/api/vote?option=cats"; echo; done
docker rm -f solo-1 solo-2
```
🔍 The `total` count jumps back and forth: each container keeps **its own** tally in memory. With five replicas, users would see five different "truths". **State belongs in a shared store.**

### Step 5: 💥 Chaos time
Hit **💥 Crash this server** in the UI a few times, as fast as you like. Then:
```bash
docker compose ps api               # some show "Up 2 seconds": restarted by the restart policy
```
The live health card shows how many requests failed while you were crashing servers. Usually zero or very few, because nginx retries on the remaining replicas.

### Step 6: Data survives `down`
```bash
docker compose down                 # removes containers and networks
docker compose up -d
```
Refresh: **votes are still there** (volume `redis-data`). `docker compose down -v` would delete the volume, and every vote with it.

### Step 7: Prove the segmentation
```bash
docker compose exec frontend wget -qO- -T 2 http://api:8080/healthz; echo     # ✅ same network
docker compose exec frontend sh -c 'nc -zv -w 2 redis 6379' || echo "frontend cannot reach redis ✅"
```

### Step 8: 🦄 "One more thing…": a release through config
```bash
cp .env.example .env
cat >> .env <<'EOF'
APP_VERSION=2.0.0
VOTE_OPTIONS=cats:🐱:Cats,dogs:🐶:Dogs,unicorns:🦄:Unicorns
EOF
docker compose up -d                # Compose recreates only what changed
```
Keep the browser open while it runs. A banner announces **version 2.0.0** and a third contender appears. 🦄 Old votes are still there.

> Compose replaces containers all at once, so you may see a short blip. Kubernetes does this as a **rolling update with zero downtime** (Lab K06).

### Step 9: Break a dependency 🧯
```bash
docker compose stop redis
sleep 15; docker compose ps          # api becomes "unhealthy"; the UI turns red and shows the errors
docker compose start redis
```
The app containers stayed **running** the whole time. Only the health check told the truth.

## 🏭 In production
- Compose is perfect for local development, CI integration tests, and small single-host deployments.
- Multi-host, self-healing across machines, rolling updates, autoscaling: that's **Kubernetes**. The concepts map directly: service → Deployment + Service, volume → PVC, healthcheck → probes, `.env` → ConfigMap/Secret.

## ✅ Checkpoint
<details><summary>1. Why does plain <code>depends_on: [redis]</code> not guarantee the app works at startup?</summary>

It only waits for the Redis container to *start*, not to be *ready*. Use `condition: service_healthy`, and make the app retry, because dependencies can disappear at any time.
</details>
<details><summary>2. Five replicas without Redis: why did the vote totals jump around?</summary>

Each replica stored votes in its own memory, and requests were spread across replicas.
</details>

## 🧹 Cleanup
```bash
docker compose down -v; rm -f .env; cd ../..
```

➡️ Next: [D09: Health Checks & Restart Policies](../09-health-restart/README.md)
