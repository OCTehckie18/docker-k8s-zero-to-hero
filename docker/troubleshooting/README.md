# 🐳 Docker Troubleshooting Scenarios

Each scenario **breaks something on purpose**. Your job is to find the evidence, explain the root cause, and fix it, the way you would during a real incident.

## How to run
From the repository root:
```bash
./labs.sh                     # interactive menu (Docker + Kubernetes)
# or directly:
./labs.sh docker 03           # break scenario D-03
./labs.sh docker 03 fix       # apply the reference fix
./labs.sh docker clean        # remove everything the scenarios created
```
Each folder has:
- `description.md`: the story, symptoms, investigation commands, hints, and the answer (collapsed, so don't peek too early)
- `break.sh`: creates the broken state
- `fix.sh`: the reference fix

## The troubleshooting loop
```
 1. Observe     what exactly is failing? (status, exit code, error message)
 2. Evidence    logs → inspect → events → from-inside checks
 3. Hypothesis  one specific, testable cause
 4. Fix         smallest safe change
 5. Verify      prove it works; don't assume
```

## Scenarios
| # | Scenario | Skill practised | Difficulty |
|---|---|---|---|
| [D-01](01-container-exits-immediately/description.md) | Container exits immediately | logs, exit codes, CMD | 🟢 |
| [D-02](02-port-already-allocated/description.md) | Port is already allocated | port publishing | 🟢 |
| [D-03](03-api-cannot-reach-redis/description.md) | Running, but the API can't connect *(class slide scenario)* | networking, `localhost` trap | 🟡 |
| [D-04](04-missing-env-var/description.md) | Database refuses to start | env config | 🟢 |
| [D-05](05-image-not-found/description.md) | Image not found | tags, registries | 🟢 |
| [D-06](06-oom-killed/description.md) | Worker dies silently | memory limits, OOMKilled | 🟡 |
| [D-07](07-volume-permission-denied/description.md) | Permission denied on a volume | non-root, ownership | 🟡 |
| [D-08](08-unhealthy-container/description.md) | Unhealthy but the app works | health checks | 🟡 |
| [D-09](09-default-bridge-dns/description.md) | Containers can't resolve each other | Docker DNS, networks | 🟡 |
| [D-10](10-build-fails-dockerignore/description.md) | Build fails: file not found | build context, .dockerignore | 🟡 |

## Universal first-response commands
```bash
docker ps -a                                   # what exists, and in what state?
docker logs --tail 50 <name>                   # what did the process say?
docker inspect <name> --format '{{json .State}}'   # exit code, OOMKilled, health
docker inspect <name> --format '{{json .Config.Env}}'
docker exec -it <name> sh                      # look from inside (if it's running)
docker stats --no-stream                       # resource pressure
```
