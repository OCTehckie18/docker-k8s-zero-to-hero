# D-02: Port is already allocated

## 📖 The story
You're starting a second copy of the web server for testing. Docker refuses with an error you skim past, and the new container sits in `Created` and never runs.

## 🔥 Symptoms
- `docker run` printed `Bind for 0.0.0.0:8085 failed: port is already allocated`
- `ts-web-2` shows status `Created`, not `Up`

## 🎯 Your mission
Get **both** web servers running and reachable from your laptop.

## 🔍 Investigate
```bash
docker ps -a --filter name=ts-web --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
docker ps --format '{{.Names}} {{.Ports}}' | grep 8085
lsof -iTCP:8085 -sTCP:LISTEN     # macOS/Linux: who is listening on the host port?
```

<details><summary>💡 Hint</summary>
Two containers can both listen on port 80 <i>inside</i> (separate network namespaces). Can two things listen on the same port on your <i>laptop</i>?
</details>
<details><summary>✅ Root cause & fix</summary>

`ts-web-1` already publishes host port **8085**. A host port can be bound by only one process. The container ports are fine; only the **host** side clashes.

```bash
docker rm -f ts-web-2
docker run -d --name ts-web-2 --label z2h.lab=ts -p 8086:80 nginx:1.27-alpine
curl -sI localhost:8085 | head -1; curl -sI localhost:8086 | head -1
```
</details>

## 🏭 Production lesson
On servers this shows up after a "zombie" old container, or a non-Docker process, still holds the port. In Kubernetes you rarely bind host ports. Services and Ingress/Gateway handle exposure, which is one reason to avoid `hostPort`.
