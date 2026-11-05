# D-10: Build fails: "file not found", but the file is right there

## 📖 The story
A developer added `*.json` to `.dockerignore` to keep large test fixtures out of the image. The next CI build fails on a `COPY` of a file that clearly exists in the folder.

## 🔥 Symptoms
```
ERROR: failed to calculate checksum ... "/config.json": not found
```

## 🎯 Your mission
Make the build pass **without** letting the test fixtures back into the image.

## 🔍 Investigate
```bash
cd /tmp/z2h-ts-build
ls -la
cat Dockerfile
cat .dockerignore
```

<details><summary>💡 Hint</summary>
<code>docker build</code> only sees files in the <b>build context</b>, after <code>.dockerignore</code> has filtered them. The file exists on disk, but does it exist in the context?
</details>
<details><summary>✅ Root cause & fix</summary>

`.dockerignore` excludes `*.json`, so `config.json` never reaches the builder. Add an exception (order matters: later lines win):
```
*.json
!config.json
```
```bash
printf '*.json\n!config.json\n' > /tmp/z2h-ts-build/.dockerignore
docker build -t z2h/ts-build /tmp/z2h-ts-build
docker run --rm z2h/ts-build
```
</details>

## 🏭 Production lesson
`.dockerignore` is a security and speed tool: it keeps `.git`, `.env` and secrets out of images and makes builds faster. Like any filter, review it when builds start "losing" files.
