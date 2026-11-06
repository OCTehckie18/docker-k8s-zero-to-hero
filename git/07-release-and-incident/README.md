# Lab G07: Release Day & the Friday Incident 🚨

> ⏱ 50 min · 🟡 Intermediate → 🔴 Advanced · Concept: [the big picture](../00-foundations/README.md#10-the-big-picture-git--docker--kubernetes)

## 📖 The story
Two weeks ago the team released **v1.0.0**, the grand-opening menu. 🎉 Since then, six commits from three people went in.

**Friday, 6:04 p.m.** A customer tweets a screenshot: **"Idli Vada ₹8 🤯"**. The weekend rush starts in an hour.
Your mission, in the order a calm on-call engineer works:
1. **Find** the exact commit that broke it, in minutes, without reading every change.
2. **Fix** it safely with a hotfix.
3. **Release** v1.0.1, with a tag everyone can trace.

## 🚀 Start here
```bash
./git/scripts/lab-start.sh 07
cd ~/z2h-git/cafe
grep "Idli Vada" menu.md          # | Idli Vada | ₹8 |  😱
```

## 🧪 Hands-on

### Step 1: What's released, and what's changed since?
```bash
git tag                                    # v1.0.0
git log --oneline --decorate v1.0.0..main  # everything since the release
```
```
c2035d1 (HEAD -> main, origin/main) feat: close at 11 pm on weekdays
7afecea feat: add Mysore Pak
4476694 docs: mention online ordering
9c730d1 refactor: align menu table columns
47e9868 feat: open at 7 am on weekdays
9d9ac2b feat: add Maddur Vada
```
Six suspects. You *could* read every diff. Or…

### Step 2: 🔎 `git bisect`: binary search through history
You know a **good** version (v1.0.0, where idli vada was ₹80) and a **bad** one (now). Git checks out the commit in the middle and asks "good or bad?", halving the suspects every time. With 1,000 commits it needs only about 10 questions.
```bash
git bisect start
git bisect bad HEAD           # now: broken
git bisect good v1.0.0        # release: fine
```
Git jumps to a commit in the middle. Test it yourself:
```bash
grep "Idli Vada" menu.md
git bisect good               # if it shows ₹80
# or:  git bisect bad          # if it shows ₹8
```
Repeat until Git announces the culprit. Or let a **script** answer every question automatically:
```bash
git bisect reset                                   # start over
git bisect start HEAD v1.0.0
git bisect run sh -c '! grep -q "Idli Vada | ₹8 |" menu.md'
```
```
9c730d1… is the first bad commit
    refactor: align menu table columns
 menu.md | 2 +-
```
```bash
git bisect reset                                   # always end with this: back to main
git show 9c730d1                                   # use your hash: the price changed in a "refactor" 🙈
```
> 🧠 "Refactor" commits should never change behaviour. That's the kind of thing review and the price check from G06 exist to catch.

### Step 3: 🚑 Hotfix on a branch
```bash
git checkout -b hotfix/idli-vada-price
git revert --no-edit 9c730d1                       # your hash
grep "Idli Vada" menu.md                       # | Idli Vada | ₹80 |  ✅
grep 'Mysore Pak' menu.md                               # later work is untouched ✅
```
In a real team, this branch goes through a fast-tracked PR: one reviewer, CI green, merge.
```bash
git checkout main
git merge --no-ff hotfix/idli-vada-price -m "Merge hotfix: idli vada back to ₹80"
git branch -d hotfix/idli-vada-price
```

### Step 4: 🏷️ Release v1.0.1
```bash
git tag -a v1.0.1 -m "Hotfix: idli vada price restored to ₹80"
git push origin main --follow-tags
git log --oneline --decorate -4
git log --oneline v1.0.0..v1.0.1                   # instant release notes
```
**Semantic versioning** (`MAJOR.MINOR.PATCH`) tells everyone what kind of release it is:

| Bump | When | Example |
|---|---|---|
| **PATCH** `1.0.0 → 1.0.1` | bug fixes only | today's hotfix |
| **MINOR** `1.0.1 → 1.1.0` | new features, nothing breaks | combo offers |
| **MAJOR** `1.1.0 → 2.0.0` | breaking changes | a brand-new website |

### Step 5: 🔗 From tag to production: the bridge to Docker and Kubernetes
In a real company, pushing the tag triggers CI, which builds the image **named after the tag**:
```bash
git describe --tags                     # v1.0.1: the version
git rev-parse --short HEAD              # the exact commit, for traceability
echo "CI would run:  docker build -t ghcr.io/your-org/vb-menu:$(git describe --tags) ."
echo "               docker push  ghcr.io/your-org/vb-menu:$(git describe --tags)"
echo "then Kubernetes rolls out:  kubectl set image deploy/menu web=ghcr.io/your-org/vb-menu:$(git describe --tags)"
```
That's the whole chain you'll build in the next tracks: **Git tag → Docker image ([D10](../../docker/10-registry-tags/README.md)) → Kubernetes rollout ([K06](../../kubernetes/06-rollouts/README.md))**. When production misbehaves, the image tag tells you the Git tag, the Git tag tells you the commits, and `bisect` finds the line.

## ✍️ Conventional Commits (you saw them in today's history)
| Prefix | Meaning | Usually bumps |
|---|---|---|
| `feat:` | a new feature | MINOR |
| `fix:` | a bug fix | PATCH |
| `docs:` / `chore:` / `refactor:` | documentation, maintenance, restructuring (no behaviour change!) | nothing |
| `feat!:` or `BREAKING CHANGE:` | an incompatible change | MAJOR |

Tools such as *semantic-release* and *release-please* read these prefixes to generate version numbers and changelogs automatically.

## 🏭 At work
- Releases are **tags** on `main`. Never ship "whatever is on Ravi's laptop".
- Hotfixes use the same flow as everything else (branch → PR → CI → merge), just faster.
- Incident write-ups (post-mortems) quote commit hashes. Git is the evidence.

## 🏆 Challenge
1. Use `git log -S "₹8 |"` to find the bad commit **without** bisect. (Why the ` |`? Because "₹8" also appears inside "₹80".) When would bisect still be better? (Hint: when you don't know what text to search for.)
2. Run `git blame menu.md` and find who last touched the Idli Vada line *after* your revert.
3. Make a `feat:` commit and tag the correct next version.

## ✅ Checkpoint
<details><summary>1. How many questions does bisect need for 1,000 commits?</summary>

About 10. Each answer halves the range (2¹⁰ = 1024).
</details>
<details><summary>2. Why revert instead of reset for the hotfix?</summary>

The bad commit is already on the shared `main` (and in production). `revert` adds a fix commit everyone can pull; `reset` would rewrite history that others already have.
</details>

🎉 **Track 0 complete!** Practise on the [Git break-and-fix scenarios](../troubleshooting/README.md), then start [Track 1 · Docker](../../docker/README.md).
