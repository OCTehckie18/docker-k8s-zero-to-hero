# Lab D10: Registries, Tags & Image Distribution

> ⏱ 35 min · 🟡 Intermediate

## 🎯 What you'll learn
- What a registry is and why teams store images there
- Tagging strategies that work in production (semver, Git SHA) and why `latest` doesn't
- Run your **own private registry** locally; push and pull
- Digests: pin the exact image you tested

## 🧠 Concept in 60 seconds
```
  laptop / CI ── docker push ──▶  Registry  ── docker pull ──▶ servers / Kubernetes nodes
                                (Docker Hub, GHCR, ECR, GCR, ACR, Harbor...)
```
An image only exists on the machine that built it until you **push** it somewhere other machines can **pull** from. A Kubernetes cluster can't run an image that lives only on your laptop.

## 🧪 Hands-on

### Step 1: Run a private registry
```bash
docker run -d --name registry -p 5001:5000 --restart unless-stopped registry:2
curl -s localhost:5001/v2/_catalog          # {"repositories":[]}
```
*(Port 5001 because macOS uses 5000 for AirPlay.)*

### Step 2: Tag and push
An image's **name tells Docker where to push it**:
```bash
docker build -t z2h/api:1.0 apps/api
docker tag z2h/api:1.0 localhost:5001/z2h/api:1.0.0
docker tag z2h/api:1.0 localhost:5001/z2h/api:1.0
docker images | grep z2h/api                 # same IMAGE ID, several names
docker push localhost:5001/z2h/api:1.0.0
docker push localhost:5001/z2h/api:1.0
curl -s localhost:5001/v2/_catalog
curl -s localhost:5001/v2/z2h/api/tags/list
```
🔍 The second push uploads almost nothing ("Layer already exists"). Registries store layers by content hash, so shared layers are stored once.

### Step 3: Pull it like a server would
```bash
docker rmi localhost:5001/z2h/api:1.0.0 localhost:5001/z2h/api:1.0
docker pull localhost:5001/z2h/api:1.0.0
docker run --rm -d --name fromreg -p 8080:8080 localhost:5001/z2h/api:1.0.0
curl -s localhost:8080/api/info; docker rm -f fromreg
```

### Step 4: Why `latest` bites
```bash
# "Release" v1 as latest
docker tag z2h/api:1.0 localhost:5001/demo:latest && docker push -q localhost:5001/demo:latest
# Someone builds a different image and pushes it as latest too
docker build -q -t localhost:5001/demo:latest - <<'EOF'
FROM busybox
CMD ["echo", "surprise! this is not the API"]
EOF
docker push -q localhost:5001/demo:latest
docker run --rm localhost:5001/demo:latest
```
Same tag, completely different software. Imagine finding out during a production incident. Now imagine trying to roll back "to the previous latest".

### Step 5: Digests: immutable identity
```bash
docker inspect localhost:5001/z2h/api:1.0.0 --format '{{index .RepoDigests 0}}'
# e.g. localhost:5001/z2h/api@sha256:3b1f...
DIGEST=$(docker inspect localhost:5001/z2h/api:1.0.0 --format '{{index .RepoDigests 0}}')
docker run --rm -d --name bydigest -p 8080:8080 "$DIGEST" && sleep 1 && curl -s localhost:8080/api/info; docker rm -f bydigest
```
A digest can never point to different content.

### Step 6 (optional): Push to Docker Hub
```bash
docker login                                  # use an access token, not your password
docker tag z2h/api:1.0 <your-dockerhub-user>/z2h-api:1.0.0
docker push <your-dockerhub-user>/z2h-api:1.0.0
```

## 🏭 A tagging strategy that works
| Tag | Example | Mutable? | Used for |
|---|---|---|---|
| Git SHA | `api:3f9c2ab` | no (by convention) | every CI build; full traceability to the commit |
| Semver | `api:1.4.2` | no (by convention) | releases |
| Moving | `api:1.4`, `api:1` | yes | convenience for consumers who accept patch updates |
| `latest` | `api:latest` | yes | local experiments only; **never in production manifests** |

Typical CI flow: **build once** → tag with Git SHA → test → scan → promote the **same digest** to staging and prod by adding tags. Never rebuild for production.

## ✅ Checkpoint
<details><summary>1. Kubernetes reports <code>ErrImagePull</code> for an image you built locally. Why?</summary>

The cluster nodes pull from a registry. Your local image isn't in any registry they can reach. Push it, or load it into the local cluster (see <code>scripts/load-image.sh</code>).
</details>
<details><summary>2. What's the difference between a tag and a digest?</summary>

A tag is a human-friendly pointer that can be moved to new content. A digest is the content's SHA-256 hash and always refers to exactly the same image.
</details>

## 🧹 Cleanup
```bash
docker rm -f registry fromreg bydigest 2>/dev/null
docker rmi localhost:5001/z2h/api:1.0.0 localhost:5001/z2h/api:1.0 localhost:5001/demo:latest 2>/dev/null
```

➡️ Next: [D11: Resource Limits & Container Security](../11-limits-security/README.md)
