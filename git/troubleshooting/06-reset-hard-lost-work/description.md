# G-06: I ran reset --hard and lost three commits

## 📖 The story
Trying to "clean up", you ran `git reset --hard HEAD~3`. Your three new menu items (two hours of work) disappeared. Your heart rate: 180. 💓

## 🔥 Symptoms
- `git log` no longer shows Cold Brew, Veg Puff or Brownie
- `menu.md` lost those rows

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/06-reset-hard-lost-work/cafe
git log --oneline
git reflog | head -6
```

<details><summary>💡 Hint 1</summary>

Commits aren't deleted straight away. The **reflog** remembers where HEAD pointed before the reset.
</details>
<details><summary>💡 Hint 2</summary>

Which `HEAD@{n}` entry is the moment *just before* the reset?
</details>
<details><summary>✅ Root cause & fix</summary>

```bash
git reflog | head -3          # HEAD@{0}: reset… · HEAD@{1}: commit: Add Brownie
git reset --hard HEAD@{1}     # go back to just before the reset
git log --oneline -4          # all three commits are back 🛟
```
</details>

## 🏭 Production lesson
`reset --hard` really destroys **uncommitted** changes, but committed work survives in the reflog (about 90 days by default). Commit often: it's your safety net.
