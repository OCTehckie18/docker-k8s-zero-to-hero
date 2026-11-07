# Lab G06: Pull Requests & Code Review: How Teams Really Merge

> ⏱ 60 min · 🟡 Intermediate · Concept: [how real teams ship a change](../00-foundations/README.md#7-how-real-teams-ship-a-change)

## 📖 The story
After the ₹1 benne dosa incident (G02), the owner made a new rule:

> *"Nothing reaches the live menu unless a second person has checked it, and the robot is happy."*

Welcome to **pull requests (PRs)**: the way almost every software team merges code. Today you'll launch **combo offers** through the full flow: branch → push → PR → automated check → review → fix → approve → merge.

## 🚀 Start here
From the course repo:
```bash
export Z2H=$PWD                      # remember where the course repo is: we'll use its check script
./git/scripts/lab-start.sh 06
```
Two terminals: **YOU** (`~/z2h-git/cafe`) and **LAKSHMI** (`~/z2h-git/lakshmi`). Run the `export Z2H=…` line in the YOU terminal.

## 🧪 Part 1: The full flow, offline

### Step 1: Branch and build the feature (YOU)
```bash
cd ~/z2h-git/cafe
git checkout -b feature/combo-offers
cat > combos.md <<'EOF'
# 🎁 Combo offers

| Combo | Price |
|---|---|
| Benne Dosa + Mysore Pak | ₹210 |
| Filter Coffee + Maddur Vada | ₹95 |
| Cold Coffee + Mysore Pak | ₹2600 |
EOF
git add combos.md
git commit -m "Add combo offers page"
git push -u origin feature/combo-offers
```
Did you spot the typo? (₹2600 instead of ₹260.) Don't fix it yet. Let's see whether the process catches it. 🕵️

### Step 2: Open the pull request 🔀
On GitHub you'd click **"Compare & pull request"**. A good PR description answers three questions. Write this in your head (or in a file for practice):
```markdown
## What
Adds a combo offers page (combos.md) with 3 combos.

## Why
Owner wants combos for the summer campaign (ticket CAFE-142).

## How to test
Open combos.md and check that the prices match the campaign sheet.
```

### Step 3: 🤖 The robot reviews first (CI)
Teams run automated checks on every PR. Here's ours, a tiny script that flags crazy prices:
```bash
bash "$Z2H/git/06-pull-requests/check-menu.sh"
```
```
❌ combos.md: suspicious price ₹2600  →  | Cold Coffee + Mysore Pak | ₹2600 |
🚫 menu check FAILED: fix the prices above before merging
```
On GitHub this shows as a red ❌ on the PR, and **the merge button stays locked**. (See [`ci-example.yml`](ci-example.yml): that's the 15-line GitHub Actions file that would run it.)

### Step 4: 👀 The human reviews (LAKSHMI)
Lakshmi fetches your branch and reviews **exactly what the PR would merge**:
```bash
cd ~/z2h-git/lakshmi
git fetch
git log --oneline main..origin/feature/combo-offers     # the commits in the PR
git diff main...origin/feature/combo-offers            # the changes in the PR (three dots!)
```
Her review comment (on GitHub it's attached to that exact line):
> 💬 *"₹2600 for cold coffee + Mysore Pak? I think you meant ₹260. Also, could we add a 'Valid until' line?"* → **Request changes**

### Step 5: Address the review (YOU)
Fix it with **new commits on the same branch**. The PR updates automatically:
```bash
cd ~/z2h-git/cafe
sed -i.bak 's/₹2600/₹260/' combos.md && rm combos.md.bak
printf '\n_Valid until 31 August._\n' >> combos.md
git commit -am "Fix cold coffee combo price; add validity date"
bash "$Z2H/git/06-pull-requests/check-menu.sh"     # ✅ menu check passed
git push
```

### Step 6: Approve and merge (LAKSHMI)
```bash
cd ~/z2h-git/lakshmi
git fetch
git diff main...origin/feature/combo-offers        # re-review: looks good ✅ Approve
git checkout main && git pull
git merge --no-ff origin/feature/combo-offers -m "Merge pull request #1 from feature/combo-offers"
git push
git push origin --delete feature/combo-offers      # GitHub's "Delete branch" button
git log --oneline --graph -5
```
🔍 `--no-ff` always creates a merge commit, just like GitHub's **"Create a merge commit"** button. It keeps a record that "PR #1 happened here".

### Step 7: Clean up your laptop (YOU)
```bash
cd ~/z2h-git/cafe
git checkout main
git pull
git branch -d feature/combo-offers
git fetch --prune            # forget remote branches that were deleted on GitHub
git log --oneline -4
```
🎉 You just shipped a feature exactly the way professional teams do.

## 🌐 Part 2: The same flow on real GitHub (optional, 15 min)
Needs a free GitHub account and the GitHub CLI (`gh auth login`).
```bash
cd ~/z2h-git/cafe
gh repo create vidyarthi-bhavan-menu --private --source . --remote github --push
git checkout -b feature/student-discount
echo "| Student discount (show ID) | -10% |" >> combos.md     # (no ₹, so the price check ignores it)
git commit -am "Add student discount"
git push -u github feature/student-discount
gh pr create --fill                     # opens the PR from your commit message
gh pr view --web                        # see it in the browser: files, checks, comments
gh pr merge --squash --delete-branch    # merge when happy
```
In the browser, explore **Files changed**: click a line number to leave a comment, then try **Review changes → Approve / Request changes**.

### Protect `main` like a real company
**Settings → Branches → Add branch ruleset / protection rule** for `main`:
- ✅ Require a pull request before merging, with **1 approval**
- ✅ Require status checks to pass (your `menu-check` workflow)
- ✅ Block force pushes

Now even *you* can't push straight to `main`. That's the point.

## 🔀 Three ways to merge a PR
| GitHub button | Result | Teams pick it when… |
|---|---|---|
| **Create a merge commit** | all commits + a merge commit | they want the full history of each PR |
| **Squash and merge** | the whole PR becomes **one** commit on main | they want a clean, one-line-per-feature history (very popular) |
| **Rebase and merge** | commits replayed on top, no merge commit | they want a linear history but keep individual commits |

## 🏭 At work
- **Small PRs get better reviews.** 200 lines get real feedback; 2,000 lines get "LGTM 👍" (looks good to me) and bugs.
- Review the **code, not the person**: "This price looks off. Did you mean ₹260?" beats "Wrong again."
- `CODEOWNERS` files auto-request the right reviewers; PR templates pre-fill the What / Why / How-to-test sections.
- Most CI checks you'll see: build, unit tests, linting, security scans, and in later tracks, **building the Docker image**.

## ✅ Checkpoint
<details><summary>1. Why did the robot catch the typo before Lakshmi did, and why do we still need Lakshmi?</summary>

Automated checks are fast and never get tired, but they only catch what they were programmed to look for. Humans catch logic, intent and design problems (the "Valid until" suggestion) that no script knows about.
</details>
<details><summary>2. After review comments, do you open a new PR?</summary>

No. Push more commits to the **same branch** and the PR updates automatically.
</details>

➡️ Next: [G07: Release Day & the Friday Incident](../07-release-and-incident/README.md)
