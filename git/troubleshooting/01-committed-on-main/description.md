# G-01: Oops, I committed on main

## 📖 The story
The team rule is *every change goes through a pull request*. You've just made two commits for the new loyalty-card feature, and then you notice the prompt says **main**. Nothing is pushed yet. Phew.

## 🔥 Symptoms
- `git status` says `Your branch is ahead of 'origin/main' by 2 commits`
- Branch protection would reject the push anyway

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/01-committed-on-main/you
git status
git log --oneline --graph --all
```

<details><summary>💡 Hint 1</summary>

A branch is just a name pointing at a commit. Could you create a **new** branch right where you are, so your two commits get a home?
</details>
<details><summary>💡 Hint 2</summary>

Once the commits are safe on the new branch, where should `main` point? (Hint: `origin/main`.)
</details>
<details><summary>✅ Root cause & fix</summary>

Create a branch where you are (it keeps the commits), move `main` back to match the remote, then continue on the branch:
```bash
git branch feature/loyalty-card       # give your two commits a branch of their own
git reset --hard origin/main          # main back to the shared state (safe: not pushed)
git checkout feature/loyalty-card
git push -u origin feature/loyalty-card   # now open a PR
```
</details>

## 🏭 Production lesson
Committing on the wrong branch happens to everyone. If it's **not pushed**, it's a 10-second fix. Make `git status` (or a shell prompt showing the branch) a habit.
