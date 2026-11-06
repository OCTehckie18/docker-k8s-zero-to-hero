# G-07: git pull refuses: "local changes would be overwritten"

## 📖 The story
You're halfway through editing the menu (not ready to commit) when Asha asks you to pull her urgent fix. `git pull` refuses.

## 🔥 Symptoms
- `git pull` prints `error: Your local changes to the following files would be overwritten by merge: menu.md`

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/07-pull-blocked-local-changes/you
git status
git diff
git pull
```

<details><summary>💡 Hint 1</summary>

Git won't mix incoming changes with your **uncommitted** ones. Can you put your work aside for a moment?
</details>
<details><summary>💡 Hint 2</summary>

There's a command that works like a drawer: put things in, take them out later.
</details>
<details><summary>✅ Root cause & fix</summary>

```bash
git stash          # put your unfinished edits in a drawer
git pull           # Asha's fix comes in cleanly
git stash pop      # take your edits back out, on top of her fix
git diff           # your work is still here ✅
```
(Alternative: commit your work first, then `git pull --rebase`.)
</details>

## 🏭 Production lesson
`git stash` is the fastest way to switch context: an urgent review, a hotfix, a quick pull. Don't leave things in the stash for weeks; `git stash list` shows what's there.
