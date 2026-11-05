# D-09: "Name or service not known" between containers

## 📖 The story
Someone moved from Compose to plain `docker run` commands to "simplify". The API now can't find Redis, even though the names are spelled correctly.

## 🔥 Symptoms
- `/readyz` returns 503 with an error mentioning name resolution
- Both containers are `Up`

## 🎯 Your mission
Make the API reach Redis **by name**.

## 🔍 Investigate
```bash
curl -s localhost:8085/readyz; echo
docker inspect ts-api ts-redis --format '{{.Name}} -> {{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}'
docker exec ts-api getent hosts ts-redis || echo "cannot resolve ts-redis"
docker exec ts-api cat /etc/resolv.conf
```

<details><summary>💡 Hint</summary>
Which network are both containers on? Which Docker networks provide DNS for container names?
</details>
<details><summary>✅ Root cause & fix</summary>

Both containers are on the **default `bridge`** network, which has **no** embedded DNS for container names. Only user-defined networks do.

```bash
docker network create --label z2h.lab=ts ts-net
docker network connect ts-net ts-redis
docker network connect ts-net ts-api
sleep 1; curl -s localhost:8085/readyz
```
(Compose creates a user-defined network automatically, which is why it "just worked" before.)
</details>

## 🏭 Production lesson
Service discovery by **name** is the foundation of every multi-service system. In Kubernetes, CoreDNS gives every Service a name like `redis.my-namespace.svc.cluster.local` (scenario K-12).
