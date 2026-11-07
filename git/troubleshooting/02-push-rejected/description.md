# G-02: My push was rejected

## 📖 The story
You fixed a typo in the opening hours and pushed. Git said no. Your teammate swears she didn't do anything wrong.

## 🔥 Symptoms
- `git push` prints `! [rejected] main -> main (fetch first)`

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/02-push-rejected/you
git push
git fetch
git status
git log --oneline --graph --all
```

<details><summary>💡 Hint 1</summary>

After `git fetch`, does `git status` say *behind*, *ahead*, or *both* (diverged)?
</details>
<details><summary>💡 Hint 2</summary>

You need Lakshmi's commit **before** yours can go on top.
</details>
<details><summary>✅ Root cause & fix</summary>

Lakshmi pushed first. Bring her commit in, put yours on top, then push:
```bash
git pull --rebase
git push
```
(Plain `git pull --no-rebase` also works, and creates a merge commit.)
</details>

## 🏭 Production lesson
A rejected push is Git **protecting your teammate's work**. Never "fix" it with `git push --force`: that deletes her commit for everyone.
