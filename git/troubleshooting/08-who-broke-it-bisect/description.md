# G-08: Who broke the filter coffee price? (bisect)

## 📖 The story
Filter Coffee shows **₹600** on the website. The last known good release is tag `v1.0`, and there are 10 commits since. Find the guilty commit in under a minute, then fix it the team-safe way.

## 🔥 Symptoms
- `grep "Filter Coffee" menu.md` shows ₹600
- `git log --oneline v1.0..main` lists 10 commits

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/08-who-broke-it-bisect/cafe
git log --oneline v1.0..main
git bisect start HEAD v1.0
```

<details><summary>💡 Hint 1</summary>

`git bisect run <command>`: the command must exit 0 for *good* and non-zero for *bad*.
</details>
<details><summary>💡 Hint 2</summary>

`! grep -q 'Filter Coffee | ₹600 |' menu.md` is "good" when ₹600 is absent.
</details>
<details><summary>✅ Root cause & fix</summary>

```bash
git bisect start HEAD v1.0
git bisect run sh -c '! grep -q "Filter Coffee | ₹600 |" menu.md'
git bisect reset
git revert --no-edit <the-first-bad-commit>
grep "Filter Coffee" menu.md          # ₹60 ✅
```
</details>

## 🏭 Production lesson
Bisect finds a bug among thousands of commits with about 10 tests. Pair it with an automated check (like G06's price check) so the bug can't come back.
