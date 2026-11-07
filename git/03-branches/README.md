# Lab G03: Branches: Build the Cold Coffee Feature Without Breaking Anything

> ⏱ 40 min · 🟢 Beginner → 🟡 Intermediate · Concept: [branches](../00-foundations/README.md#5-branches-a-safe-draft-copy)

## 📖 The story
Summer is coming. The owner wants **Cold Coffee** on the menu, but the price isn't decided yet, and the website must keep working while you experiment. Rule of the team: **`main` is always ready to go live.** So you'll work on a **branch**.

## 🚀 Start here
```bash
./git/scripts/lab-start.sh 03
cd ~/z2h-git/cafe
```

## 🧪 Hands-on

### Step 1: Create a branch, then move onto it
Two commands, two jobs:
```bash
git branch                          # list branches:  * main   ← the * is "you are here"
git branch add-cold-coffee          # 1. CREATE the draft copy (you're still on main!)
git branch                          #    add-cold-coffee  /  * main
git checkout add-cold-coffee        # 2. MOVE onto it
git branch
```
```
* add-cold-coffee
  main
```
> ⚡ **Shortcut used every day:** `git checkout -b add-cold-coffee` creates **and** moves in one go.
> 🆕 You'll also see `git switch add-cold-coffee` / `git switch -c add-cold-coffee`: the same job under a newer name. See [checkout vs switch](#-git-checkout-vs-git-switch-know-both) below.

### Step 2: Work and commit on the branch
```bash
echo "| Cold Coffee | ₹??? |" >> menu.md
git commit -am "Add cold coffee (price TBD)"
sed -i.bak 's/Cold Coffee | ₹???/Cold Coffee | ₹180/' menu.md && rm menu.md.bak
git commit -am "Price cold coffee at ₹180"
git log --oneline --graph --all -5
```
```
* 9f2c1d0 (HEAD -> add-cold-coffee) Price cold coffee at ₹180
* 41b7a2e Add cold coffee (price TBD)
* e040db2 (main) Ignore secret files
```
🔍 Your draft (`add-cold-coffee`) moved forward two commits. `main`, the menu customers see, stayed exactly where it was.

> `git commit -am` stages **all modified tracked files** and commits in one step. It's handy, but it won't include brand-new files.

### Step 3: ✨ The magic trick: switch universes
```bash
git checkout main
grep "Cold Coffee" menu.md || echo "no cold coffee on main 🙈"
git checkout add-cold-coffee
grep "Cold Coffee" menu.md         # it's back
```
Your **files on disk actually change** as you switch branches. Same folder, two versions of reality. That's why customers (on `main`) never see half-finished work.

### Step 4: Merge it (fast-forward)
The owner approves ₹180. Bring it into `main`:
```bash
git checkout main
git merge add-cold-coffee
```
```
Updating e040db2..9f2c1d0
Fast-forward
 menu.md | 1 +
```
🔍 **Fast-forward**: `main` hadn't moved since you branched, so Git simply moves `main` forward to your draft's latest commit. No new commit needed.
```bash
git branch -d add-cold-coffee      # the draft did its job: delete its name (the commits are now in main)
```

### Step 5: Two branches at once → a real merge commit
Real life is messier: while you work on one thing, `main` moves on.
```bash
git checkout -b update-hours
sed -i.bak 's/8 am – 10 pm/7 am – 10 pm/' hours.md && rm hours.md.bak
git commit -am "Open at 7 am on weekdays"

git checkout main
printf '# 📖 Vidyarthi Bhavan website\n\nThe menu and opening hours of our café.\n' > README.md
git add README.md && git commit -m "Add README"

git merge update-hours -m "Merge branch 'update-hours'"
git log --oneline --graph -6
```
```
*   5c1e9aa (HEAD -> main) Merge branch 'update-hours'
|\
| * 2d4b6f1 (update-hours) Open at 7 am on weekdays
* | 8a7e3c2 Add README
|/
* 9f2c1d0 Price cold coffee at ₹180
```
🔍 Both branches had new commits, so Git created a **merge commit** with **two parents**: the diamond in the graph. Different files changed, so there was no conflict. (Same line? That's G05. 😈)
```bash
git branch -d update-hours
```

## 🔀 `git checkout` vs `git switch`: know both
You'll meet **both** at work: older scripts, tutorials and many teams use `checkout`, while newer docs use `switch`. They move you between branches in exactly the same way.

**Why two commands?** `git checkout` used to do two unrelated jobs: **switching branches** *and* **restoring files** (`git checkout -- menu.md`). That confused people, so Git 2.23 (2019) split it into `git switch` (branches) and `git restore` (files). `checkout` still works and isn't going away.

| Action | Classic: `git checkout` | Modern: `git switch` |
|---|---|---|
| Move to an existing branch | `git checkout cold-coffee` | `git switch cold-coffee` |
| Create a branch **and** move to it | `git checkout -b cold-coffee` | `git switch -c cold-coffee` |
| Toggle back to the previous branch | `git checkout -` | `git switch -` |
| Start a branch from the team's latest main | `git checkout -b hotfix origin/main` | `git switch -c hotfix origin/main` |
| Work on a teammate's branch (exists only on GitHub) | `git checkout lakshmi-feature` | `git switch lakshmi-feature` |
| Look at an old commit (detached HEAD) | `git checkout a1f3c9e` | `git switch --detach a1f3c9e` |
| Throw away uncommitted edits to a file | `git checkout -- menu.md` | `git restore menu.md` *(the files job moved to `restore`)* |

Try the toggle, the one people love:
```bash
git checkout main        # or: git switch main
git checkout -           # back to the branch you were just on (or: git switch -)
git checkout -           # …and back again
```

🔍 Two safety details worth knowing:
- Asking for a teammate's branch that you don't have yet (`git switch lakshmi-feature`) automatically creates a local copy that **tracks** `origin/lakshmi-feature`. Same with `checkout`.
- `git switch a1f3c9e` **refuses** ("a branch is expected, got commit"). You must say `--detach` on purpose. `git checkout a1f3c9e` quietly puts you in detached HEAD. That's one reason `switch` was introduced.

### "Your local changes would be overwritten": switching with uncommitted work
If you've edited a file that is also different on the target branch, **both** commands stop you:
```
error: Your local changes to the following files would be overwritten by checkout:
	menu.md
Please commit your changes or stash them before you switch branches.
```
Pick one:
| Option | Commands | Your edits |
|---|---|---|
| ✅ **Commit** them first | `git commit -am "WIP: …"`, then switch | kept, on the current branch |
| ✅ **Stash** them (put them in a drawer) | `git stash`, then switch, and later `git stash pop` | kept, brought back when you pop |
| 🛑 **Force** the switch | `git checkout -f <branch>` / `git switch -f <branch>` | **thrown away for good** |

> 🧠 **Remember:** `checkout -b` = `switch -c`, `checkout -` = `switch -`. Use whichever your team uses, and recognise both. Full list: [Git cheat sheet](../../cheatsheets/git.md).

## 🏷️ Branch names teams actually use
| Prefix | For | Example |
|---|---|---|
| `feature/` | new functionality | `feature/cold-coffee` |
| `fix/` or `bugfix/` | bugs | `fix/benne dosa-price` |
| `hotfix/` | urgent production fixes | `hotfix/payment-down` |
| `chore/` / `docs/` | maintenance, documentation | `docs/update-readme` |
Many companies also add a ticket number: `feature/CAFE-142-cold-coffee`.

## 🏭 At work
- One branch per task, kept **small and short-lived** (hours to a few days). Long-lived branches mean painful merges.
- You rarely merge into `main` on your laptop. You push the branch and open a **pull request** (G06), and the merge happens on GitHub after review.

## 🏆 Challenge
1. Create `feature/maddur-vada`, add a row, commit, and merge it. Was it a fast-forward? Why?
2. Run `git log --oneline --graph --all` and draw the result on paper.
3. Create a branch, commit, then try `git branch -d` on it **without merging** it. Read Git's warning: why does it protect you?

## ✅ Checkpoint
<details><summary>1. When does Git fast-forward, and when does it create a merge commit?</summary>

Fast-forward when the target branch (`main`) has no new commits since you branched: the label just moves. A merge commit when both branches have new commits.
</details>
<details><summary>2. Does deleting a merged branch delete its commits?</summary>

No. The commits are now part of `main`'s history; only the label is removed.
</details>

➡️ Next: [G04: Teamwork: Push, Pull and the Rejected Push](../04-teamwork-remote/README.md)
