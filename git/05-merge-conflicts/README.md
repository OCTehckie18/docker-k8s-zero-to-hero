# Lab G05: Merge Conflicts: the Ghee Roast Dosa Price War 🥞⚔️

> ⏱ 40 min · 🟡 Intermediate · Concept: [merge conflicts](../00-foundations/README.md#8-merge-conflicts)

## 📖 The story
Two good intentions, one line of text:
- 👩 **Asha** switched to pure desi ghee: *ghee roast dosa ₹150 → ₹180*.
- 🧑 **You** heard rice prices went up: *ghee roast dosa ₹150 → ₹160*.

Neither knew about the other. Git can't decide who's right, and it shouldn't. Let's experience the conflict and resolve it calmly.

## 🚀 Start here
```bash
./git/scripts/lab-start.sh 05        # "GitHub" + your clone + Asha's clone, all in sync
```
Use two terminals again: **YOU** (`cd ~/z2h-git/cafe`) and **ASHA** (`cd ~/z2h-git/asha`).

## 🧪 Hands-on

### Step 1: Asha changes the price and ships it first (ASHA)
```bash
cd ~/z2h-git/asha
sed -i.bak 's/Ghee Roast Dosa | ₹150/Ghee Roast Dosa | ₹180/' menu.md && rm menu.md.bak
git commit -am "Ghee Roast Dosa ₹180: pure desi ghee"
git push
```

### Step 2: You change the same line on your branch (YOU)
```bash
cd ~/z2h-git/cafe
git checkout -b fix/ghee-roast-price
sed -i.bak 's/Ghee Roast Dosa | ₹150/Ghee Roast Dosa | ₹160/' menu.md && rm menu.md.bak
git commit -am "Ghee Roast Dosa ₹160: rice prices went up"
```

### Step 3: Bring your branch up to date with main 💥
Before asking for a review, good engineers merge the latest `main` into their branch:
```bash
git fetch
git merge origin/main
```
```
Auto-merging menu.md
CONFLICT (content): Merge conflict in menu.md
Automatic merge failed; fix conflicts and then commit the result.
```

### Step 4: Read the evidence
```bash
git status
```
```
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)
Unmerged paths:
	both modified:   menu.md
```
```bash
grep -n -A4 '<<<<<<<' menu.md
```
```
<<<<<<< HEAD
| Ghee Roast Dosa | ₹160 |
=======
| Ghee Roast Dosa | ₹180 |
>>>>>>> origin/main
```
| Marker | Means |
|---|---|
| `<<<<<<< HEAD` | start of **your** version (the branch you're on) |
| `=======` | divider |
| `>>>>>>> origin/main` | end of **their** version (what you're merging in) |

🔍 Notice what **didn't** conflict: every other line merged automatically. Git only asks about the one line you both changed.

### Step 5: Talk, decide, resolve 🤝
You message Asha. You agree: **₹170**, pure desi ghee *and* a fair price. Open `menu.md` in any editor, replace the whole marked block with the agreed line, and **delete all three marker lines**:
```
| Ghee Roast Dosa | ₹170 |
```
<details><summary>No editor handy? A one-liner that does the same</summary>

```bash
sed -i.bak '/^<<<<<<< /,/^>>>>>>> /c\
| Ghee Roast Dosa | ₹170 |
' menu.md && rm menu.md.bak
```
</details>

Then tell Git it's resolved, and finish the merge:
```bash
grep -c '<<<<<<<\|>>>>>>>' menu.md     # 0: no markers left (always check!)
git add menu.md                        # "add" = mark as resolved
git commit --no-edit                   # completes the merge with the default message
git log --oneline --graph -5
```

### Step 6: Ship it
```bash
git checkout main
git pull
git merge fix/ghee-roast-price
git push
grep 'Ghee Roast' menu.md                 # | Ghee Roast Dosa | ₹170 |  ✅
```
**ASHA:** `git pull && grep 'Ghee Roast' menu.md`: everyone agrees. ☕🤝

### Step 7: The emergency exit 🚪
Sometimes you start a merge and realise you're not ready. Make a conflict on purpose, then back out:
```bash
git checkout -b experiment
sed -i.bak 's/Filter Coffee | ₹60/Filter Coffee | ₹65/' menu.md && rm menu.md.bak && git commit -qam "Coffee ₹65"
git checkout -b experiment-2 main
sed -i.bak 's/Filter Coffee | ₹60/Filter Coffee | ₹70/' menu.md && rm menu.md.bak && git commit -qam "Coffee ₹70"
git merge experiment                # CONFLICT
git merge --abort                   # everything back exactly as before the merge
git status                          # clean
git checkout main && git branch -D experiment experiment-2
```

## 🧯 Resolving conflicts: the checklist
1. `git status`: which files are "both modified"?
2. Open each one and find the `<<<<<<<` markers.
3. **Talk to the other person** if you're not sure what's right.
4. Edit to the correct final text and **remove every marker**.
5. `git add <file>` for each file, then `git commit` (or `git rebase --continue` if you were rebasing).
6. Run the app or tests. A clean merge can still be logically wrong.

> 💻 **VS Code** shows buttons above each conflict: *Accept Current*, *Accept Incoming*, *Accept Both*, plus a 3-way **merge editor**. Same concept, nicer UI.

## 🏭 At work: how teams keep conflicts rare
- **Small, short-lived branches**: merge within a day or two.
- **Pull `main` often** into your branch, so you see conflicts while they're tiny.
- **Communicate**: "I'm reworking the menu file today" in the team chat saves hours.
- Pull requests show "This branch has conflicts that must be resolved" before anything can merge.

## ✅ Checkpoint
<details><summary>1. Will two people adding rows at different places in menu.md conflict?</summary>

Usually not. Git merges different lines automatically. Changes to the same or directly adjacent lines conflict.
</details>
<details><summary>2. You resolved the file but forgot <code>git add</code>, then ran <code>git commit</code>. What happens?</summary>

Git refuses: "Committing is not possible because you have unmerged files." `git add` is how you mark a conflict as resolved.
</details>

➡️ Next: [G06: Pull Requests & Code Review](../06-pull-requests/README.md)
