# 🌿 Git Break-and-Fix Scenarios

Eight emergencies every developer meets in their first months on a team. Each one creates a throwaway sandbox in `/tmp/z2h-git-ts/`, breaks it the realistic way, and leaves you to investigate. Your real work is never touched.

## How to run
From the repository root:
```bash
./labs.sh                 # interactive menu (Git, Docker and Kubernetes)
./labs.sh git 03          # break scenario G-03
./labs.sh git 03 fix      # apply the reference fix
./labs.sh git clean       # delete all sandboxes
```
Each folder has `description.md` (story, symptoms, hints, and the answer, hidden), `break.sh` and `fix.sh`.

## The calm-developer loop
```
1. git status                        where am I? what's going on?
2. git log --oneline --graph --all   what does history look like?
3. git reflog                        where have I been? (nothing committed is truly lost)
4. read the message                  Git's hints usually tell you the exact command
5. fix → verify (git status / log)
```

## Scenarios
| # | Emergency | You'll use | Level |
|---|---|---|---|
| [G-01](01-committed-on-main/description.md) | Oops, I committed on `main` | `branch`, `reset --hard origin/main` | 🟢 |
| [G-02](02-push-rejected/description.md) | My push was rejected | `pull --rebase`, `push` | 🟢 |
| [G-03](03-detached-head-lost-commit/description.md) | Where did my commit go? (detached HEAD) | `reflog`, `branch <hash>` | 🟡 |
| [G-04](04-merge-conflict/description.md) | A merge stopped halfway | resolve, `add`, `commit` / `merge --abort` | 🟢 |
| [G-05](05-committed-a-secret/description.md) | I committed a secret 🔐 | `rm --cached`, `.gitignore`, `commit --amend` | 🟡 |
| [G-06](06-reset-hard-lost-work/description.md) | `reset --hard` ate my commits | `reflog`, `reset --hard HEAD@{1}` | 🟡 |
| [G-07](07-pull-blocked-local-changes/description.md) | `git pull` refuses: local changes | `stash`, `pull`, `stash pop` | 🟢 |
| [G-08](08-who-broke-it-bisect/description.md) | Who broke the filter coffee price? | `bisect run`, `revert` | 🔴 |
