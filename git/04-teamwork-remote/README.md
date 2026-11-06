# Lab G04: Teamwork: Push, Pull, and the Rejected Push

> ⏱ 50 min · 🟡 Intermediate · Concept: [local and remote](../00-foundations/README.md#6-local-and-remote-everyone-has-the-full-history)

## 📖 The story
Until now the menu lived only on your laptop. If it's stolen, the café's website history is gone. 😬 Asha wants the code on the team's **shared repository**, and she'll start working on it too.

To make this work **offline, on one laptop**, we'll simulate the whole team:

| Folder | Plays the role of |
|---|---|
| `~/z2h-git/github/cafe.git` | ☁️ **GitHub**: the shared copy |
| `~/z2h-git/cafe` | 🧑 **your** laptop |
| `~/z2h-git/asha` | 👩 **Asha's** laptop |

> 💡 Open **two terminal windows** side by side, labelled "YOU" and "ASHA". It feels like real teamwork. In a classroom, pair up and let two people play the roles.

## 🚀 Start here
```bash
./git/scripts/lab-start.sh 04
cd ~/z2h-git/cafe
```

## 🧪 Hands-on

### Step 1: Create "GitHub" and connect to it (terminal YOU)
```bash
git init --bare -b main ~/z2h-git/github/cafe.git     # an empty shared repo, like clicking "New repository"
git remote add origin ~/z2h-git/github/cafe.git        # name it "origin"
git remote -v
git push -u origin main                                 # upload all history; -u remembers the pairing
```
```
origin	/Users/you/z2h-git/github/cafe.git (fetch)
origin	/Users/you/z2h-git/github/cafe.git (push)
…
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```
> 🌐 With real GitHub, the only difference is the address: `git remote add origin https://github.com/<you>/cafe.git`. (Or let the GitHub CLI do it all: `gh repo create cafe --private --source . --push`.)

### Step 2: Asha joins the team (terminal ASHA)
```bash
git clone ~/z2h-git/github/cafe.git ~/z2h-git/asha
cd ~/z2h-git/asha
git config user.name  "Asha (Lead Dev)"       # this repo only, so she signs her own commits
git config user.email "asha@beanbyte.cafe"
git log --oneline -3                           # she has the FULL history already
```

### Step 3: Asha pushes a change (terminal ASHA)
```bash
sed -i.bak 's/Sunday: 9 am – 6 pm/Sunday: 10 am – 6 pm/' hours.md && rm hours.md.bak
git commit -am "Open at 10 am on Sundays"
git push
```

### Step 4: You catch up (terminal YOU)
```bash
cd ~/z2h-git/cafe
git status                         # "Your branch is up to date". Hmm, really?
git fetch                          # ask GitHub what's new (changes nothing in your files)
git status                         # "Your branch is behind 'origin/main' by 1 commit"
git log --oneline main..origin/main    # exactly what you're missing
git pull                           # fetch + merge into your branch
grep Sunday hours.md               # Sunday: 10 am – 6 pm
```
🔍 `git status` only knows what your laptop knew at the last **fetch**. `git pull` = `git fetch` + bring the changes in.

### Step 5: 💥 The rejected push
Both of you work at the same time, and Asha is faster.

**ASHA:**
```bash
cd ~/z2h-git/asha && git pull -q
echo "| Veg Puff | ₹45 |" >> menu.md
git commit -am "Add Veg Puff" && git push
```
**YOU** (still at your old commit):
```bash
cd ~/z2h-git/cafe
printf '\n☎️ Call us: +91 80 1234 5678\n' >> README.md
git commit -am "Add phone number to README"
git push
```
```
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to '…/cafe.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. …
```
😱 Don't panic: **nothing is broken**. Git refuses to let you overwrite Asha's work. You need her commit first:
```bash
git pull --rebase          # put YOUR commit on top of hers
git push                   # ✅ accepted
git log --oneline --graph -4
```
```
* 7c3d9e1 (HEAD -> main, origin/main) Add phone number to README
* 4b8a2f6 Add Veg Puff
* …
```
🔍 `--rebase` replays your local commit **on top of** Asha's, giving a clean straight line. (Plain `git pull` would create a merge commit instead. Both are fine; many teams prefer rebase for local catch-ups.)

### Step 6: Asha syncs too (terminal ASHA)
```bash
cd ~/z2h-git/asha && git pull && git log --oneline -3
```
Both laptops and "GitHub" now hold identical history. That's a healthy team. ✅

## 🧭 The daily routine (print this!)
```bash
git switch main && git pull          # 1. start the day up to date
git switch -c feature/my-task        # 2. work on a branch
#   …edit, git add, git commit (often)…
git pull --rebase origin main        # 3. catch up with the team before pushing
git push -u origin feature/my-task   # 4. share it, then open a pull request (G06)
```

## 🏭 At work
- `origin` is usually `git@github.com:company/repo.git` (SSH) or an HTTPS URL. You authenticate with an SSH key or a token, never your password.
- **Pull before you push, every time.** A rejected push is Git protecting your teammate's work, not an error.
- Never use `git push --force` on a shared branch. If you must rewrite your own feature branch, use `--force-with-lease`.

## ✅ Checkpoint
<details><summary>1. fetch vs pull?</summary>

`fetch` downloads new commits and updates `origin/main` but leaves your branch and files alone. `pull` fetches **and** integrates them into your current branch.
</details>
<details><summary>2. Why was your push rejected, and why is that good?</summary>

The remote had a commit (Asha's) that you didn't have. Pushing would have thrown it away, so Git refuses until you integrate it.
</details>

➡️ Next: [G05: Merge Conflicts: the Cappuccino Price War](../05-merge-conflicts/README.md)
