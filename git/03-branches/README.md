# Lab G03: Branches: Build the Cold Brew Feature Without Breaking Anything

> ⏱ 40 min · 🟢 Beginner → 🟡 Intermediate · Concept: [branches](../00-foundations/README.md#5-branches-sticky-notes-that-move)

## 📖 The story
Summer is coming. The owner wants **Cold Brew** on the menu, but the price isn't decided yet, and the website must keep working while you experiment. Rule of the team: **`main` is always ready to go live.** So you'll work on a **branch**.

## 🚀 Start here
```bash
./git/scripts/lab-start.sh 03
cd ~/z2h-git/cafe
```

## 🧪 Hands-on

### Step 1: Create a branch and move onto it
```bash
git branch                       # * main  ← the * is "you are here" (HEAD)
git switch -c add-cold-brew      # create + switch, in one go
git branch
```
```
* add-cold-brew
  main
```

### Step 2: Work and commit on the branch
```bash
echo "| Cold Brew | ₹??? |" >> menu.md
git commit -am "Add cold brew (price TBD)"
sed -i.bak 's/Cold Brew | ₹???/Cold Brew | ₹180/' menu.md && rm menu.md.bak
git commit -am "Price cold brew at ₹180"
git log --oneline --graph --all -5
```
```
* 9f2c1d0 (HEAD -> add-cold-brew) Price cold brew at ₹180
* 41b7a2e Add cold brew (price TBD)
* e040db2 (main) Ignore secret files
```
🔍 The `add-cold-brew` sticky note moved forward two commits. `main` stayed exactly where it was.

> `git commit -am` stages **all modified tracked files** and commits in one step. It's handy, but it won't include brand-new files.

### Step 3: ✨ The magic trick: switch universes
```bash
git switch main
grep "Cold Brew" menu.md || echo "no cold brew on main 🙈"
git switch add-cold-brew
grep "Cold Brew" menu.md         # it's back
```
Your **files on disk actually change** as you switch branches. Same folder, two versions of reality. That's why customers (on `main`) never see half-finished work.

### Step 4: Merge it (fast-forward)
The owner approves ₹180. Bring it into `main`:
```bash
git switch main
git merge add-cold-brew
```
```
Updating e040db2..9f2c1d0
Fast-forward
 menu.md | 1 +
```
🔍 **Fast-forward**: `main` hadn't moved since you branched, so Git simply slides the `main` sticky note forward. No new commit needed.
```bash
git branch -d add-cold-brew      # the branch did its job: delete the sticky note (the commits stay)
```

### Step 5: Two branches at once → a real merge commit
Real life is messier: while you work on one thing, `main` moves on.
```bash
git switch -c update-hours
sed -i.bak 's/8 am – 10 pm/7 am – 10 pm/' hours.md && rm hours.md.bak
git commit -am "Open at 7 am on weekdays"

git switch main
printf '# 📖 Bean & Byte Café website\n\nThe menu and opening hours of our café.\n' > README.md
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
* 9f2c1d0 Price cold brew at ₹180
```
🔍 Both branches had new commits, so Git created a **merge commit** with **two parents**: the diamond in the graph. Different files changed, so there was no conflict. (Same line? That's G05. 😈)
```bash
git branch -d update-hours
```

## 🏷️ Branch names teams actually use
| Prefix | For | Example |
|---|---|---|
| `feature/` | new functionality | `feature/cold-brew` |
| `fix/` or `bugfix/` | bugs | `fix/espresso-price` |
| `hotfix/` | urgent production fixes | `hotfix/payment-down` |
| `chore/` / `docs/` | maintenance, documentation | `docs/update-readme` |
Many companies also add a ticket number: `feature/CAFE-142-cold-brew`.

## 🏭 At work
- One branch per task, kept **small and short-lived** (hours to a few days). Long-lived branches mean painful merges.
- You rarely merge into `main` on your laptop. You push the branch and open a **pull request** (G06), and the merge happens on GitHub after review.

## 🏆 Challenge
1. Create `feature/veg-puff`, add a row, commit, and merge it. Was it a fast-forward? Why?
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
