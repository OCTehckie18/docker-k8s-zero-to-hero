# Lab D06: Volumes & Persistent Data

> ⏱ 40 min · 🟢 Beginner → 🟡 Intermediate

## 🎯 What you'll learn
- Why container data disappears, and how to keep it
- **Named volumes** vs **bind mounts** vs **tmpfs**
- Run a real database whose data survives container replacement
- Back up and restore a volume

## 🧠 Concept in 60 seconds

```
                ┌──────────── container ─────────────┐
                │  writable layer  (deleted with it)  │
                │  ─────────────────────────────────  │
                │  /data  ◀── mount ─────────────┐    │
                └────────────────────────────────┼────┘
                                                 │
  named volume  (managed by Docker, survives) ───┤
  bind mount    (a folder on your laptop)    ────┤
  tmpfs         (RAM only, never on disk)    ────┘
```
| Type | Syntax | Use for |
|---|---|---|
| Named volume | `-v pgdata:/var/lib/postgresql/data` | databases, any data the app owns |
| Bind mount | `-v "$PWD/site":/usr/share/nginx/html` | local development, live code reload, config files |
| tmpfs | `--tmpfs /tmp` | scratch or sensitive data that should never touch disk |

## 🧪 Hands-on

### Step 1: Prove the problem
```bash
docker run -d --name db1 -e POSTGRES_PASSWORD=devpass postgres:16-alpine
sleep 5
docker exec db1 psql -U postgres -c "CREATE TABLE notes(t text); INSERT INTO notes VALUES ('important!');"
docker exec db1 psql -U postgres -c "SELECT * FROM notes;"
docker rm -f db1
docker run -d --name db1 -e POSTGRES_PASSWORD=devpass postgres:16-alpine
sleep 5
docker exec db1 psql -U postgres -c "SELECT * FROM notes;"     # ERROR: relation "notes" does not exist
docker rm -f db1
```
💥 The data was gone. It lived in the container's writable layer.

### Step 2: Fix it with a named volume
```bash
docker volume create pgdata
docker run -d --name db2 -e POSTGRES_PASSWORD=devpass -v pgdata:/var/lib/postgresql/data postgres:16-alpine
sleep 5
docker exec db2 psql -U postgres -c "CREATE TABLE notes(t text); INSERT INTO notes VALUES ('survives!');"

docker rm -f db2                                         # destroy the container
docker run -d --name db3 -e POSTGRES_PASSWORD=devpass -v pgdata:/var/lib/postgresql/data postgres:16-alpine
sleep 5
docker exec db3 psql -U postgres -c "SELECT * FROM notes;"     # survives!
```
```bash
docker volume ls
docker volume inspect pgdata
```
🔍 This is exactly how you **upgrade** a database container: stop the old one and start a new image version on the same volume. *(Always back up first, and check the database's upgrade notes.)*

### Step 3: Bind mount for live development
```bash
mkdir -p /tmp/site && echo "<h1>v1</h1>" > /tmp/site/index.html
docker run -d --name dev -p 8080:80 -v /tmp/site:/usr/share/nginx/html:ro nginx:1.27-alpine
curl -s localhost:8080
echo "<h1>v2: edited on my laptop</h1>" > /tmp/site/index.html
curl -s localhost:8080                         # changed instantly, no rebuild
docker exec dev sh -c 'echo hack > /usr/share/nginx/html/index.html'   # fails: :ro = read-only
docker rm -f dev
```

### Step 4: Back up and restore a volume
The pattern: start a throwaway container that mounts **both** the volume and a host folder, then tar the data.
```bash
docker stop db3
docker run --rm -v pgdata:/source:ro -v /tmp:/backup alpine \
  tar czf /backup/pgdata-backup.tgz -C /source .
ls -lh /tmp/pgdata-backup.tgz

docker volume create pgdata-restored
docker run --rm -v pgdata-restored:/target -v /tmp:/backup alpine \
  tar xzf /backup/pgdata-backup.tgz -C /target
docker run -d --name db4 -e POSTGRES_PASSWORD=devpass -v pgdata-restored:/var/lib/postgresql/data postgres:16-alpine
sleep 5; docker exec db4 psql -U postgres -c "SELECT * FROM notes;"
```

### Step 5: tmpfs
```bash
docker run --rm --tmpfs /scratch:size=16m alpine sh -c 'df -h /scratch; echo secret > /scratch/x; cat /scratch/x'
```

### Step 6: 🎬 Back to the Showdown: votes that survive
Remember the cliffhanger in Lab D03? Let's fix it for real. The votes go into **Redis**, and Redis keeps its data on a **named volume**:
```bash
docker network create showdown
docker run -d --name redis --network showdown -v votes:/data redis:7-alpine redis-server --appendonly yes
docker run -d --name app   --network showdown -p 8080:8080 -e REDIS_HOST=redis z2h/api:1.0
```
Open http://localhost:8080: the badge now says **💾 votes in Redis**. Vote like crazy. Then destroy **everything**:
```bash
docker rm -f app redis
docker run -d --name redis --network showdown -v votes:/data redis:7-alpine redis-server --appendonly yes
docker run -d --name app   --network showdown -p 8080:8080 -e REDIS_HOST=redis z2h/api:1.0
```
Refresh. **The votes are still there.** 🎉 Both containers are brand new; the data lived on the volume the whole time. *(Networks like `showdown` are explained in the next lab.)*
```bash
docker rm -f app redis; docker network rm showdown; docker volume rm votes
```

## 🏭 In production
- Copying a volume's files while the database is running can produce a **corrupt** backup. Use the database's own tool (`pg_dump`, `mysqldump`) or stop it first, as we did.
- Running containers with a read-only root filesystem (`--read-only`) and explicit volumes for writable paths is a strong security baseline (Lab D11).
- In Kubernetes, the same idea becomes **PersistentVolumes** and **PersistentVolumeClaims** (Lab K10).

## 🏆 Challenge
1. Mount the same named volume into two containers at once. Write a file from one and read it from the other.
2. `docker volume prune` removes unused volumes. Which of your volumes would it delete right now, and why is it dangerous on a server?

## ✅ Checkpoint
<details><summary>1. Does <code>docker rm</code> delete named volumes?</summary>

No. Volumes outlive containers. `docker rm -v` removes only *anonymous* volumes. Named volumes require `docker volume rm`.
</details>
<details><summary>2. When would you prefer a bind mount over a named volume?</summary>

Local development (editing code or config on the host) or when the host path is meaningful. For application data, named volumes are portable and managed by Docker.
</details>

## 🧹 Cleanup
```bash
docker rm -f db1 db2 db3 db4 dev 2>/dev/null
docker volume rm pgdata pgdata-restored 2>/dev/null
rm -rf /tmp/site /tmp/pgdata-backup.tgz
```

➡️ Next: [D07: Container Networking](../07-networking/README.md)
