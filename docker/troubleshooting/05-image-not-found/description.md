# D-05: Image not found

## 📖 The story
The release notes say "upgrade nginx to 1.99". The upgrade command fails and the old version is still running.

## 🔥 Symptoms
- `docker run` fails with `manifest unknown` / `not found`
- No `ts-img` container is running

## 🎯 Your mission
Find out which tags actually exist and run a valid nginx version.

## 🔍 Investigate
```bash
docker pull nginx:1.99.99-alpine
docker manifest inspect nginx:1.27-alpine >/dev/null && echo "1.27-alpine exists"
# list real tags (needs curl + internet):
curl -s 'https://hub.docker.com/v2/repositories/library/nginx/tags?page_size=10&name=alpine' | grep -o '"name":"[^"]*"' | head
```

<details><summary>💡 Hint</summary>
There are three classic causes: a typo in the image name, a tag that does not exist, or a private image you are not logged in to. Which error message did you get?
</details>
<details><summary>✅ Root cause & fix</summary>

The tag `1.99.99-alpine` does not exist. Use a real tag:
```bash
docker run -d --name ts-img --label z2h.lab=ts -p 8085:80 nginx:1.27-alpine
```
Error message decoder:
| Message | Usually means |
|---|---|
| `manifest unknown` / `not found` | the tag does not exist |
| `pull access denied ... repository does not exist or may require 'docker login'` | typo in the name **or** a private repository |
| `toomanyrequests` | Docker Hub rate limit: log in or use a mirror |
</details>

## 🏭 Production lesson
In Kubernetes this becomes `ErrImagePull` → `ImagePullBackOff` (scenario K-02). Pin real, tested tags in Git, and let CI verify that the image exists **before** deploying.
