# G-04: A merge stopped halfway (conflict)

## 📖 The story
You tried to merge `chai-price` into `main` and Git stopped with CONFLICT. Now every command feels risky. The team agreed the chai price is **₹70**.

## 🔥 Symptoms
- `git status` shows `You have unmerged paths` and `both modified: menu.md`

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/04-merge-conflict/cafe
git status
grep -n -A4 '<<<<<<<' menu.md
```

<details><summary>💡 Hint 1</summary>

The file contains both versions between `<<<<<<<`, `=======` and `>>>>>>>`.
</details>
<details><summary>💡 Hint 2</summary>

Keep the agreed line, delete all the markers, then mark the file as resolved.
</details>
<details><summary>✅ Root cause & fix</summary>

Edit `menu.md` so the block becomes one line, `| Masala Chai | ₹70 |`, with no markers left. Then:
```bash
grep -c '<<<<<<<' menu.md      # 0
git add menu.md
git commit --no-edit
```
Want to give up instead? `git merge --abort` puts everything back.
</details>

## 🏭 Production lesson
Conflicts are a normal part of teamwork. Always check that no markers are left (`grep '<<<<<<<'`) before committing: committed markers break builds.
