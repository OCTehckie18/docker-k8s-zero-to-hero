# Lab G01: Day 1 at Bean & Byte Café: Your First Repository

> ⏱ 40 min · 🟢 Beginner · Needs: Git installed (`git --version`) · Concepts: [G00](../00-foundations/README.md)

## 📖 The story
It's your first day on the café's tech team. 🎉 Asha, the lead developer, hands you your first task:

> *"Put our menu online, and track it with Git from minute one. In this team, if it isn't committed, it doesn't exist."*

## 🎯 What you'll learn
`git config` · `git init` · `git status` · `git add` · `git commit` · `git log` · `git diff` · `git show`, and how to write commit messages people actually like.

## 🧪 Hands-on

### Step 1: Tell Git who you are (once per computer)
Every commit is signed with a name and email. That's the "who" in "who changed the price?"
```bash
git --version
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global --list | grep -E 'user|init'
```
> Already used Git before? Run `git config --global user.name`. If it prints your name, skip this step.

### Step 2: Create the project and turn on Git
```bash
mkdir -p ~/z2h-git/cafe && cd ~/z2h-git/cafe
git init
ls -a          # a hidden .git folder appeared: that IS the repository (all history lives there)
git status
```
```
Initialized empty Git repository in /Users/you/z2h-git/cafe/.git/
On branch main
No commits yet
nothing to commit (create/copy files and use "git add" to track)
```

### Step 3: Write the menu
```bash
cat > menu.md <<'EOF'
# ☕ Bean & Byte Café: Menu

| Item | Price |
|---|---|
| Espresso | ₹120 |
| Cappuccino | ₹150 |
| Masala Chai | ₹60 |
| Filter Coffee | ₹80 |
EOF
git status
```
```
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	menu.md
```
🔍 **Untracked** means Git sees the file but isn't looking after it yet.

### Step 4: Stage it, then commit it 📸
```bash
git add menu.md        # choose who's in the photo
git status             # "Changes to be committed: new file: menu.md" (now green)
git commit -m "Add menu with 4 items"
```
```
[main (root-commit) a9cca9d] Add menu with 4 items
 1 file changed, 8 insertions(+)
 create mode 100644 menu.md
```
Your first save point. 🎉 The `a9cca9d` is its ID (yours will be different).

### Step 5: Two changes, two clean commits
Asha asks for opening hours, **and** the owner raises the espresso price. Do both, then look:
```bash
printf '# 🕗 Opening hours\n\nMon–Sat: 8 am – 10 pm\nSunday: 9 am – 6 pm\n' > hours.md
sed -i.bak 's/Espresso | ₹120/Espresso | ₹130/' menu.md && rm menu.md.bak
git status             # menu.md modified · hours.md untracked
git diff               # exactly what changed, line by line
```
```diff
-| Espresso | ₹120 |
+| Espresso | ₹130 |
```
These are **two different ideas**, so they become **two commits**. That's what the staging area is for:
```bash
git add hours.md
git commit -m "Add opening hours"
git add menu.md
git commit -m "Raise espresso to ₹130 (new bean supplier)"
```

### Step 6: Read the history
```bash
git log                    # full details: hash, author, date, message
git log --oneline          # one line per commit
git log --stat             # which files each commit touched
git show HEAD              # the latest commit, including its diff
```
```
d1e2f3a (HEAD -> main) Raise espresso to ₹130 (new bean supplier)
7634a68 Add opening hours
a9cca9d Add menu with 4 items
```
🔍 Read it bottom-up: that's the story of your first day, saved forever.

## ✍️ Commit messages: what real teams expect
| ❌ Unhelpful | ✅ Helpful |
|---|---|
| `update` | `Raise espresso to ₹130 (new bean supplier)` |
| `fix` | `Fix wrong Sunday closing time on hours page` |
| `asdfgh` | `Add Masala Chai to the menu` |
| `final changes!!` | `Remove discontinued Cold Coffee` |

Rules of thumb: start with a verb ("Add", "Fix", "Remove"), keep it under about 60 characters, and say **why** if it isn't obvious. Many companies use **Conventional Commits** (`feat: add chai`, `fix: sunday hours`), which you'll meet in G07.

## 🏭 At work
- Your company usually gives you a **repository to clone** rather than starting with `git init`. You'll do that in G04.
- Many teams set up a commit-message format check in CI, so `fix stuff` won't even be accepted.
- Use your **work email** in `user.email`. It links your commits to your GitHub or GitLab account.

## 🏆 Challenge
1. Add a `| Masala Chai Latte | ₹90 |` row and commit it with a good message.
2. Change **two** prices, but commit only **one** of them. (Hint: `git add -p menu.md` lets you pick individual changes.)
3. Find out how many lines your first commit added, using only `git show`.

## ✅ Checkpoint
<details><summary>1. What's the difference between "untracked", "modified" and "staged"?</summary>

Untracked: Git has never been asked to look after the file. Modified: a tracked file changed since the last commit. Staged: the change is chosen for the next commit (`git add`).
</details>
<details><summary>2. Where does Git keep the history?</summary>

In the hidden `.git` folder at the top of the project. Delete it and the history is gone, but your current files stay.
</details>

➡️ Next: [G02: Time Travel & Undo: "Who set espresso to ₹1?"](../02-time-travel-undo/README.md)
