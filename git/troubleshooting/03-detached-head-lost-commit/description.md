# G-03: Where did my commit go? (detached HEAD)

## 📖 The story
You went back in time to look at an old menu, liked an idea, and committed the secret-recipe note right there. Then you switched back to `main`, and your commit vanished from `git log`.

## 🔥 Symptoms
- `git log` on main doesn't show "Add secret recipe note"
- Git printed a warning about leaving a commit behind when you switched

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/03-detached-head-lost-commit/cafe
git log --oneline --all
git reflog | head -5
```

<details><summary>💡 Hint 1</summary>

A commit made in detached HEAD belongs to **no branch**. But Git remembers everywhere HEAD has been.
</details>
<details><summary>💡 Hint 2</summary>

Find the commit's hash in `git reflog`, then put a branch on it.
</details>
<details><summary>✅ Root cause & fix</summary>

```bash
git reflog | grep "secret recipe"        # e.g. 4f1a2b3 HEAD@{1}: commit: Add secret recipe note
git branch secret-recipe 4f1a2b3         # rescue it with a branch (use your hash)
git merge secret-recipe                  # bring it into main, if you want it there
```
</details>

## 🏭 Production lesson
Detached HEAD is perfect for **looking** at the past. Before committing there, run `git checkout -b <name>`. Lost commits stay in the reflog for about 90 days.
