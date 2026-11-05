# D-04: The database refuses to start

## 📖 The story
A new developer copied the `docker run` command for Postgres from the wiki but "cleaned it up" first. The database container dies right after starting.

## 🔥 Symptoms
- `ts-db` shows `Exited (1)`

## 🎯 Your mission
Get Postgres running and accepting queries.

## 🔍 Investigate
```bash
docker ps -a --filter name=ts-db
docker logs ts-db
docker inspect ts-db --format '{{json .Config.Env}}'
```

<details><summary>💡 Hint</summary>
The log message is very explicit. Official images document their required environment variables on their Docker Hub page.
</details>
<details><summary>✅ Root cause & fix</summary>

The official `postgres` image refuses to initialise without `POSTGRES_PASSWORD` (or an explicit opt-out). The variable was removed.

```bash
docker rm -f ts-db
docker run -d --name ts-db --label z2h.lab=ts -e POSTGRES_PASSWORD=devpass postgres:16-alpine
sleep 5; docker exec ts-db psql -U postgres -c 'select version();'
```
</details>

## 🏭 Production lesson
Apps should **fail fast with a clear message** when required config is missing, as Postgres does here. In production, the password comes from a secret store (Docker secrets, a Kubernetes Secret, Vault), never from a wiki or a Git repository.
