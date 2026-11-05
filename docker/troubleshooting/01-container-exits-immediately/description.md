# D-01: The container exits immediately

## 📖 The story
A teammate changed the run command for the API in a deployment script. Now the container "starts" and is gone a second later. They say: *"Docker is broken, it won't stay up."*

## 🔥 Symptoms
- `docker ps` does not show `ts-exits`
- `docker ps -a` shows `Exited (2)`

## 🎯 Your mission
Find out **why** it exits and get the Showdown running on http://localhost:8085.

## 🔍 Investigate
```bash
docker ps -a --filter name=ts-exits
docker logs ts-exits
docker inspect ts-exits --format '{{.Config.Cmd}} exit={{.State.ExitCode}}'
docker run --rm z2h/api:1.0 ls /app
```

<details><summary>💡 Hint 1</summary>
A container lives exactly as long as its main process. What did the main process say before it died?
</details>
<details><summary>💡 Hint 2</summary>
Compare the command in <code>.Config.Cmd</code> with the files that actually exist in <code>/app</code>.
</details>
<details><summary>✅ Root cause & fix</summary>

The command was overridden to `python server.py`, but the file in the image is `app.py`. Python exits with code 2: `can't open file '/app/server.py'`.

Fix: drop the bad override so the image's own `CMD` is used (or pass the right file):
```bash
docker rm -f ts-exits
docker run -d --name ts-exits --label z2h.lab=ts -p 8085:8080 z2h/api:1.0
curl -s localhost:8085/api/info
```
</details>

## 🏭 Production lesson
"Exits immediately" is almost never Docker's fault. **Read the logs of the dead container first.** Exit code 2 or 127 usually means a wrong command or path. In Kubernetes the same bug appears as `CrashLoopBackOff` (scenario K-03).
