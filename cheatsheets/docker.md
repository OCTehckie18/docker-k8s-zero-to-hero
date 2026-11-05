# 🐳 Docker Cheat Sheet

## Run
```bash
docker run -d --name web -p 8080:80 nginx:1.27-alpine   # background, named, port published
docker run --rm -it alpine sh                            # interactive, auto-delete on exit
docker run -e KEY=value --env-file .env IMAGE            # environment
docker run -v data:/data -v "$PWD":/src:ro IMAGE         # named volume + read-only bind mount
docker run --network mynet --restart unless-stopped IMAGE
docker run --memory 256m --cpus 0.5 --user 10001 --read-only --cap-drop ALL IMAGE
```

## Inspect & debug
```bash
docker ps / docker ps -a                     # running / all containers
docker logs -f --tail 50 NAME                # follow logs
docker exec -it NAME sh                      # shell inside
docker inspect NAME --format '{{.State.ExitCode}} {{.State.OOMKilled}}'
docker inspect NAME --format '{{json .Config.Env}}'
docker stats --no-stream                     # CPU / memory
docker top NAME                              # processes
docker port NAME                             # published ports
docker cp NAME:/path ./local                 # copy files out
docker events --since 10m                    # what the engine did
```

## Lifecycle
```bash
docker stop NAME   docker start NAME   docker restart NAME   docker kill NAME
docker rm -f NAME                            # stop + remove
docker container prune -f                    # remove all stopped containers
```

## Images
```bash
docker build -t name:1.0 .                   # build from ./Dockerfile
docker build -f path/Dockerfile -t name:1.0 context/
docker images / docker image ls
docker image history name:1.0                # layers
docker tag name:1.0 registry.example.com/team/name:1.0
docker push registry.example.com/team/name:1.0
docker pull nginx:1.27-alpine
docker rmi name:1.0   ·   docker image prune -a
```

## Networks & volumes
```bash
docker network create mynet   ·   docker network ls   ·   docker network inspect mynet
docker network connect mynet NAME
docker volume create data     ·   docker volume ls    ·   docker volume rm data
```

## Compose
```bash
docker compose up -d --build                 # start / update everything
docker compose ps   ·   docker compose logs -f SERVICE
docker compose up -d --scale SERVICE=3
docker compose exec SERVICE sh
docker compose down          # remove containers + networks
docker compose down -v       # ...and volumes (data!)
```

## Exit codes
| Code | Meaning |
|---|---|
| 0 | success |
| 1–2 | app error / misuse (e.g. file not found) |
| 125 | `docker run` itself failed |
| 126 / 127 | not executable / command not found |
| 137 | SIGKILL: OOM or `docker kill` (check `OOMKilled`) |
| 143 | SIGTERM: normal stop |

## Cleanup everything (⚠️ local machine only)
```bash
docker system df            # what's using space
docker system prune -a      # remove unused containers, networks, images
```
