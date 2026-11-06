# G-05: I committed a secret 🔐

## 📖 The story
You added the payment-gateway key to `.env` for local testing, then ran `git add .` and committed along with a menu change. **It's not pushed yet.** Your team lead's rule: *secrets never enter Git history*.

## 🔥 Symptoms
- `git show --stat HEAD` lists `.env`
- `git log -p | grep API_KEY` finds the key

## 🔍 Investigate
```bash
cd /tmp/z2h-git-ts/05-committed-a-secret/cafe
git show --stat HEAD
git log -p | grep API_KEY
```

<details><summary>💡 Hint 1</summary>

You need to remove the file **from the commit** but keep it on your disk.
</details>
<details><summary>💡 Hint 2</summary>

Then make sure Git ignores it forever, and rewrite the (unpushed) commit.
</details>
<details><summary>✅ Root cause & fix</summary>

```bash
git rm --cached .env                 # stop tracking it, keep the file on disk
echo ".env" >> .gitignore
git add .gitignore
git commit --amend --no-edit         # rewrite the last commit without the secret
git log -p | grep API_KEY || echo "secret is gone from history ✅"
```
</details>

## 🏭 Production lesson
🚨 **If it had been pushed:** assume it's leaked. **Revoke and rotate the key immediately**, then clean the history (`git filter-repo` or BFG) and tell your security team. Bots scan public GitHub for keys within minutes. Prevention: `.gitignore` from day one, and secret scanning (GitHub push protection, gitleaks) in CI.
