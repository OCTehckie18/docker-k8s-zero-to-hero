# G00 Quiz: Git Foundations 🧠

30 questions. Answer before you peek. 24+ means you're ready for G01.

## Part A: Concepts (12)

<details><summary><b>A1.</b> What problem does version control solve?</summary>

Knowing which version is current, who changed what, when and why, going back to earlier versions, and letting many people work on the same files without overwriting each other.
</details>
<details><summary><b>A2.</b> Git vs GitHub?</summary>

Git is the version-control tool on your computer, and it works offline. GitHub is a website that hosts Git repositories and adds teamwork features: pull requests, reviews, issues, Actions (CI).
</details>
<details><summary><b>A3.</b> What does a commit contain?</summary>

A snapshot of all tracked files, the author and date, a message, and a pointer to its parent commit. It's identified by a unique hash such as `c94e1aa`.
</details>
<details><summary><b>A4.</b> Name the three areas a change moves through.</summary>

Working directory → staging area (`git add`) → repository (`git commit`).
</details>
<details><summary><b>A5.</b> Why does the staging area exist?</summary>

To choose exactly which changes go into the next commit, so one messy editing session can become several clean commits.
</details>
<details><summary><b>A6.</b> What is a branch?</summary>

A movable label (a "sticky note") pointing at a commit. It moves forward each time you commit on it.
</details>
<details><summary><b>A7.</b> What is HEAD?</summary>

"You are here": the branch (or commit) you currently have checked out.
</details>
<details><summary><b>A8.</b> What is <code>origin</code>?</summary>

The default name for the remote repository you cloned from, usually the team's shared copy on GitHub.
</details>
<details><summary><b>A9.</b> Why is Git called "distributed"?</summary>

Every clone has the full history, so you can commit, branch and look at the history offline. There's no single machine you depend on.
</details>
<details><summary><b>A10.</b> What is a pull request?</summary>

A request to merge one branch into another (usually `main`), where teammates review the changes and automated checks (CI) run before the merge.
</details>
<details><summary><b>A11.</b> When does a merge conflict happen?</summary>

When two branches change the same lines (or one edits a file the other deleted). Git can't decide, so it asks a human.
</details>
<details><summary><b>A12.</b> Who created Git, and why?</summary>

Linus Torvalds, in 2005, to manage development of the Linux kernel after its previous tool became unavailable.
</details>

## Part B: Real-world scenarios (8)

<details><summary><b>B1.</b> Customers see the wrong price on the website. How does Git help find out how it happened?</summary>

`git log -p menu.md` or `git blame menu.md` shows which commit changed that line, who made it, when, and with what message. `git revert` then undoes it safely.
</details>
<details><summary><b>B2.</b> You want to try a risky redesign without breaking the working site. What do you do?</summary>

Create a branch (`git switch -c redesign`), work and commit there, and merge only when it's ready. `main` stays untouched.
</details>
<details><summary><b>B3.</b> You committed on your laptop, but your teammate says she doesn't see your change. Why?</summary>

Commits are local until you `git push` them to the shared remote, and she then needs to `git pull`.
</details>
<details><summary><b>B4.</b> Why do companies block direct pushes to <code>main</code>?</summary>

So every change goes through a pull request with review and automated checks: fewer bugs, a clear record, and a controlled release.
</details>
<details><summary><b>B5.</b> A bad commit is already on the shared <code>main</code>. Reset or revert?</summary>

Revert. It adds a new commit that undoes the change without rewriting the history your teammates already have.
</details>
<details><summary><b>B6.</b> You're about to commit and notice <code>passwords.txt</code> is staged. What now?</summary>

`git restore --staged passwords.txt`, then add it to `.gitignore`. Never commit secrets: once pushed, assume they're leaked and change them.
</details>
<details><summary><b>B7.</b> Two teammates edited different files on different branches. Will merging cause a conflict?</summary>

No. Git merges changes to different files, or different lines, automatically.
</details>
<details><summary><b>B8.</b> How does a Git tag relate to what runs in production?</summary>

A release tag (for example `v1.4.2`) marks the exact commit that was released. CI typically builds the Docker image from it (`shop:1.4.2`), and that image is deployed.
</details>

## Part C: Commands (5)

<details><summary><b>C1.</b> Which command should you run whenever you're unsure what's going on?</summary>

`git status`.
</details>
<details><summary><b>C2.</b> Which command moves changes into the staging area?</summary>

`git add <file>` (or `git add .` for everything in the current folder).
</details>
<details><summary><b>C3.</b> Create a new branch and switch to it, in one command.</summary>

`git switch -c <branch-name>`.
</details>
<details><summary><b>C4.</b> Get a copy of a remote repository for the first time.</summary>

`git clone <url>`.
</details>
<details><summary><b>C5.</b> See a compact history with the branch structure.</summary>

`git log --oneline --graph --all`.
</details>

## Part D: Troubleshooting (5)

<details><summary><b>D1.</b> <code>git push</code> is rejected: "Updates were rejected because the remote contains work that you do not have locally". Why, and what's the fix?</summary>

A teammate pushed first. Run `git pull --rebase` (or `git pull`), resolve any conflicts, then `git push` again.
</details>
<details><summary><b>D2.</b> You ran <code>git reset --hard</code> and your last commits are gone. Are they lost?</summary>

Almost certainly not. `git reflog` lists where HEAD has been; `git reset --hard <hash>` (or creating a branch at that hash) brings them back.
</details>
<details><summary><b>D3.</b> Git says "You are in 'detached HEAD' state". Is that dangerous?</summary>

No. You're looking at a specific commit instead of a branch. If you make commits there and want to keep them, create a branch: `git switch -c keep-my-work`. Otherwise `git switch main` takes you back.
</details>
<details><summary><b>D4.</b> A merge stops with "CONFLICT (content): Merge conflict in menu.md". What are the steps?</summary>

Open the file, choose the correct text between the markers, delete the markers, `git add menu.md`, then `git commit`. To back out completely: `git merge --abort`.
</details>
<details><summary><b>D5.</b> <code>git pull</code> fails with "Your local changes would be overwritten by merge". What do you do?</summary>

Commit your changes first, or set them aside with `git stash`, run `git pull`, then `git stash pop` to bring them back.
</details>

⬅️ [Back to G00](README.md) · ➡️ [G01: Your First Repository](../01-first-repo/README.md)
