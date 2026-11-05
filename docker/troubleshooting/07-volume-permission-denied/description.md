# D-07: Permission denied on a volume

## 📖 The story
Security asked the team to stop running containers as root. The uploader now runs as UID 10001, as it should. Since then it crashes writing to its data volume.

## 🔥 Symptoms
- `ts-uploader` exits with code 1
- Logs: `Permission denied`

## 🎯 Your mission
Keep the container **non-root** and make it work. Going back to root is not an acceptable fix.

## 🔍 Investigate
```bash
docker logs ts-uploader
docker inspect ts-uploader --format 'user={{.Config.User}} mounts={{json .Mounts}}'
docker run --rm -v ts-uploads:/data alpine ls -ln /data          # numeric owners
docker run --rm z2h/api:1.0 id
```

<details><summary>💡 Hint</summary>
Compare the numeric owner (UID) of <code>/data/uploads</code> with the UID the container runs as.
</details>
<details><summary>✅ Root cause & fix</summary>

The volume directory `/data/uploads` was created by root (`0:0`, mode 755). UID 10001 can read it but cannot write to it.

Fix the **ownership of the data**, not the user of the app. A one-off root "init" container is a common pattern:
```bash
docker run --rm -v ts-uploads:/data alpine chown -R 10001:10001 /data/uploads
docker start ts-uploader
sleep 3; docker logs --tail 3 ts-uploader
```
</details>

## 🏭 Production lesson
In Kubernetes the same fix is `securityContext.fsGroup` (Kubernetes adjusts volume group ownership for you) or an `initContainer` that runs `chown`. Never "fix" this with `runAsUser: 0` or `chmod 777`.
