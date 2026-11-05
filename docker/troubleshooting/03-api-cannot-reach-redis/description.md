# D-03: Everything is running, but the API cannot connect

## 📖 The story
*(This is the exact scenario from the class slides.)* The release went out. `docker ps` shows every container **Up**. Users report that every vote fails.

```
 Browser ──▶ API (Up) ──✖──▶ Redis (Up)
```

## 🔥 Symptoms
- Voting in the UI at http://localhost:8085 fails (the top bar turns red); `curl "localhost:8085/api/vote?option=cats"` returns **503** with a connection error
- `curl localhost:8085/readyz` returns **503**
- All containers are `Up`

## 🎯 Your mission
Make voting work again. Find the evidence before you change anything.

## 🔍 Investigate
```bash
docker ps --filter label=z2h.lab=ts
curl -s localhost:8085/readyz; echo
docker logs ts-api | tail -5
docker inspect ts-api --format '{{json .Config.Env}}'
docker inspect ts-api --format '{{json .NetworkSettings.Networks}}' | python3 -m json.tool | grep -E '"(NetworkID|IPAddress)"|ts-net'
docker run --rm --network ts-net busybox nslookup ts-redis
```

<details><summary>💡 Hint 1</summary>
Check the layers one by one: is the name right? Does DNS resolve it? Is the port open? Are credentials right?
</details>
<details><summary>💡 Hint 2</summary>
Inside a container, what does <code>localhost</code> point to?
</details>
<details><summary>✅ Root cause & fix</summary>

`REDIS_HOST=localhost`. Inside the API container, `localhost` is the API container itself, and nothing listens on 6379 there. Redis is a **different container**, reachable by its name `ts-redis` on network `ts-net`.

```bash
docker rm -f ts-api
docker run -d --name ts-api --label z2h.lab=ts --network ts-net -p 8085:8080 -e REDIS_HOST=ts-redis z2h/api:1.0
sleep 1; curl -s "localhost:8085/api/vote?option=cats"
```
</details>

## 🏭 Production lesson
**A running container is not the same as a healthy, reachable service.** Common causes: wrong host/service name, wrong port, different networks, wrong credentials, or the dependency is not ready yet. A readiness check like `/readyz` turns this hidden failure into a visible signal.
