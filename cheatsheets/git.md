# 🌿 Git Cheat Sheet

Wherever two commands do the same job, both are shown: **classic** (`git checkout`, works everywhere, very common at work) and **modern** (`git switch` / `git restore`, Git 2.23+). Use whichever your team uses, and recognise both.

## One-time setup
```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git --version
```

## Start a project
```bash
git init                         # turn the current folder into a repository
git clone <url>                  # copy an existing repository (full history)
git clone <url> my-folder        # …into a folder name of your choice
```

## Everyday loop
```bash
git status                       # what changed? what's staged? what next?  (run constantly)
git diff                         # unstaged changes, line by line
git diff --staged                # what's about to be committed
git add <file>                   # stage a file   ·   git add .  = everything here
git add -p                       # stage piece by piece (pick individual changes)
git commit -m "Add filter coffee to the menu"
git commit -am "…"               # stage all modified tracked files + commit (not new files)
```

## Look at history
```bash
git log --oneline                # one line per commit
git log --oneline --graph --all  # with branch structure
git log -p -- menu.md            # every change ever made to one file
git log -S "₹1 |" --oneline      # commits that added or removed this text
git show <commit>                # one commit, with its diff
git blame menu.md                # who last changed each line, and in which commit
```

## Branches: classic vs modern
| Action | Classic: `git checkout` | Modern: `git switch` |
|---|---|---|
| List branches (`*` = you are here) | `git branch` | `git branch` |
| Create a branch (stay where you are) | `git branch cold-coffee` | `git branch cold-coffee` |
| Move to an existing branch | `git checkout cold-coffee` | `git switch cold-coffee` |
| Create **and** move | `git checkout -b cold-coffee` | `git switch -c cold-coffee` |
| Toggle to the previous branch | `git checkout -` | `git switch -` |
| New branch from the team's latest main | `git checkout -b hotfix origin/main` | `git switch -c hotfix origin/main` |
| Teammate's branch (only on GitHub so far) | `git checkout lakshmi-feature` | `git switch lakshmi-feature` |
| Visit an old commit (detached HEAD) | `git checkout <commit>` | `git switch --detach <commit>` |
| Back to the present | `git checkout main` | `git switch main` |
| Discard local edits while switching ⚠️ | `git checkout -f <branch>` | `git switch -f <branch>` |

```bash
git branch -d cold-coffee        # delete a merged branch (safe: refuses if unmerged)
git branch -D cold-coffee        # force-delete an unmerged branch ⚠️
git branch -m new-name           # rename the current branch
git branch -a                    # include remote branches
```
> Local changes blocking the switch ("would be overwritten by checkout")? **Commit** them, or `git stash` → switch → `git stash pop`. `-f` throws them away.

## Merge & conflicts
```bash
git merge cold-coffee            # bring a branch into the current one
git merge --no-ff feature -m "…" # always create a merge commit (like GitHub's merge button)
git merge --abort                # back out of a conflicted merge
# resolve: edit the file, remove <<<<<<< ======= >>>>>>> markers, then:
git add menu.md && git commit    # (or: git rebase --continue during a rebase)
```

## Remotes: working with the team
```bash
git remote -v                    # where is "origin"?
git remote add origin <url>
git push -u origin main          # first push of a branch (-u remembers the pairing)
git push                         # later pushes
git fetch                        # download news, change nothing locally
git pull                         # fetch + merge into the current branch
git pull --rebase                # fetch + replay your commits on top (clean history)
git push origin --delete <branch>
git fetch --prune                # forget branches deleted on the remote
```

## Undo: classic vs modern
| Situation | Classic | Modern | Safe after pushing? |
|---|---|---|---|
| Throw away edits in a file | `git checkout -- menu.md` | `git restore menu.md` | n/a (edits lost) |
| Un-stage a file | `git reset HEAD menu.md` | `git restore --staged menu.md` | ✅ |
| Get a file as it was in a commit | `git checkout <commit> -- menu.md` *(also stages it)* | `git restore --source <commit> menu.md` *(leaves it unstaged)* | ✅ |
| Fix the last commit | `git commit --amend` | (same) | ❌ local only |
| Undo a commit, keeping history | `git revert <commit>` | (same) | ✅ the team-safe way |
| Remove local commits | `git reset --hard HEAD~1` | (same) | ❌ destructive |
| Find "lost" commits | `git reflog` | (same) | ✅ |

## Put work aside
```bash
git stash                        # park uncommitted changes
git stash list
git stash pop                    # bring the latest back
git stash drop                   # throw the latest away
```

## Releases & investigation
```bash
git tag -a v1.0.1 -m "Hotfix: idli vada price"   # annotated release tag
git push origin main --follow-tags
git describe --tags              # e.g. v1.0.1: great for Docker image tags
git bisect start HEAD v1.0.0     # find the commit that broke something
git bisect run sh -c '! grep -q "Idli Vada | ₹8 |" menu.md'
git bisect reset
```

## Golden rules
1. **`git status` first.** Its hints usually tell you the exact next command.
2. **Commit small and often**, with messages that say *why*.
3. **Never commit secrets.** Use `.gitignore`; if one leaks, rotate it.
4. **Pull before you push.** A rejected push protects a teammate's work.
5. **Never rewrite pushed history.** Use `revert`, not `reset`, and never `push --force` on shared branches.
6. **Lost something? `git reflog`.** Committed work is almost never truly gone.

📖 Learn it hands-on: [Track 0 · Git](../git/README.md) · Official docs: [git checkout](https://git-scm.com/docs/git-checkout) · [git switch](https://git-scm.com/docs/git-switch) · [git restore](https://git-scm.com/docs/git-restore)
