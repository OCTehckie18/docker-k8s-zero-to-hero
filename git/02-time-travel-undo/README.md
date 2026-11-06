# Lab G02: Time Travel & Undo: "Who Set Benne Dosa to ₹1?"

> ⏱ 50 min · 🟢 Beginner → 🟡 Intermediate · Map: [the undo diagram](../00-foundations/README.md#9-oops-which-undo-do-i-need)

## 📖 The story
Monday, 8:05 a.m. The café phone won't stop ringing: the website says **benne dosa costs ₹1**. ☕💸
Over the weekend, Ravi the intern "borrowed your laptop" to "tidy things up". Time to investigate like a professional: **find the evidence, fix it safely, prevent it next time.**

## 🚀 Start here
```bash
./git/scripts/lab-start.sh 02        # from the course repo: rebuilds ~/z2h-git/cafe with Ravi's weekend commits
cd ~/z2h-git/cafe
cat menu.md                          # | Benne Dosa | ₹1 |  😱
```

## 🧪 Hands-on

### Step 1: 🕵️ What happened while you were away?
```bash
git log --oneline
git log --format='%h  %an  %ar  %s'
```
```
3bdd711  Ravi (Intern)  2 minutes ago  Tidy up menu formatting
6905157  Ravi (Intern)  2 minutes ago  Add Badam Milk
32c5a32  You            2 minutes ago  Raise benne dosa to ₹130
...
```

### Step 2: Who changed THAT line?
```bash
git blame menu.md
```
```
3bdd711a (Ravi (Intern) …) | Benne Dosa | ₹1 |
```
`git blame` shows, for every line, the commit and person that last changed it. Now look at that commit:
```bash
git show 3bdd711          # use YOUR hash from the blame output
```
```diff
-| Benne Dosa | ₹130 |
+| Benne Dosa | ₹1 |
```
🔍 "Tidy up formatting" actually changed a price. **This is exactly why reviews exist** (G06): a second pair of eyes would have caught it.

> 💡 `git blame` sounds harsh. Teams use it to find **context** ("why was this changed?"), not to blame people. Ravi isn't in trouble: the missing review process is.

### Step 3: ✅ Fix it the team-safe way: revert
```bash
git revert --no-edit 3bdd711
git log --oneline -3
grep 'Benne Dosa' menu.md               # | Benne Dosa | ₹130 |  ✅
```
`revert` doesn't erase history. It adds a **new commit that does the opposite**. The record shows the mistake *and* the fix, which is what you want once others have the commit.

### Step 4: Undo edits you haven't committed
You start "improving" the menu, then change your mind:
```bash
echo "| Gold-Leaf Dosa | ₹9999 |" >> menu.md
git diff                            # shows the new line
git restore menu.md                 # back to the last commit
git diff                            # nothing
```

### Step 5: 🔐 The secret that almost escaped
```bash
echo "WIFI_PASSWORD=vb-wifi-2026" > secrets.txt
git add .
git status                          # secrets.txt is staged!  🚨
git restore --staged secrets.txt    # un-stage it (the file stays on disk)
echo "secrets.txt" >> .gitignore
echo ".env" >> .gitignore
git status                          # secrets.txt is gone from the list: Git now ignores it
git add .gitignore
git commit -m "Ignore secret files"
```
> 🏭 In real companies, a committed password, API key or token is a **security incident**. Once it's pushed, assume it's leaked and **change it**: deleting the commit afterwards is not enough. `.gitignore` is your seatbelt. ([Scenario G-05](../troubleshooting/README.md) practises the clean-up.)

### Step 6: Fix your last commit (before you push)
A typo in the message, and you forgot a file:
```bash
printf 'Happy hour: 4–6 pm, 20%% off all filter coffee\n' > offers.md
git add offers.md
git commit -m "Add hapy hour"
git commit --amend -m "Add happy hour offer"       # fix the message
git log --oneline -2
```
`--amend` replaces the last commit. It's fine **only if you haven't pushed it**, because it rewrites history.

### Step 7: ⏪ Visit the past (detached HEAD)
What did the menu look like on day one?
```bash
git log --oneline | tail -1                 # the very first commit
git checkout HEAD~7                  # jump back 7 commits: day one
cat menu.md                                  # the original 4-item menu
git status                                   # "HEAD detached at …"
git checkout main                              # back to the present
```
🔍 **Detached HEAD** just means you're looking at an old commit instead of a branch. It's perfect for looking around. If you start making commits there, create a branch first (`git checkout -b …`).

### Step 8: 💥 The scary one: reset --hard, and the rescue
Simulate the worst mistake: throwing away your last two commits.
```bash
git log --oneline -3
git reset --hard HEAD~2          # "delete" the last 2 commits
git log --oneline -3             # they're gone! 😱
git reflog | head -5             # …but Git remembers everywhere HEAD has been
git reset --hard HEAD@{1}        # go back to where we were one move ago
git log --oneline -3             # restored 🛟
```
> 🧠 `reset --hard` destroys **uncommitted** work for real, but committed work almost always survives in the **reflog** (about 90 days by default). Knowing this saves careers.

## 🗺️ Your undo cheat sheet
| Situation | Command | Safe after pushing? |
|---|---|---|
| Throw away edits in a file | `git restore <file>` | n/a (edits are lost) |
| Un-stage a file | `git restore --staged <file>` | ✅ |
| Fix the last commit | `git commit --amend` | ❌ local only |
| Undo a commit | `git revert <hash>` | ✅ the team-safe way |
| Remove local commits | `git reset --hard <where>` | ❌ local only, destructive |
| Find "lost" commits | `git reflog` | ✅ |

## 🏆 Challenge
1. Use `git log -p -- hours.md` to see every change ever made to the hours file.
2. Use `git log -S "Badam Milk"` to find the commit that **introduced** that text.
3. Make a commit, `git reset --hard HEAD~1`, then rescue it with the reflog, without peeking at Step 8.

## ✅ Checkpoint
<details><summary>1. A bad commit is already on the shared main. revert or reset?</summary>

`revert`. It adds an undo commit; teammates just pull it. `reset` rewrites history and breaks everyone else's copies.
</details>
<details><summary>2. Is <code>git restore menu.md</code> reversible?</summary>

No. Uncommitted edits it throws away were never saved by Git. That's why `git diff` comes first.
</details>

➡️ Next: [G03: Branches: Build the Cold Coffee Feature Safely](../03-branches/README.md)
