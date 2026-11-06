#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/08-who-broke-it-bisect/cafe" || exit 1
git bisect start HEAD v1.0 >/dev/null
bad=$(git bisect run sh -c '! grep -q "Masala Chai | ₹600 |" menu.md' | grep 'is the first bad commit' | cut -c1-7)
git bisect reset >/dev/null 2>&1
ok "first bad commit: $bad"
git revert --no-edit "$bad" >/dev/null
grep "Masala Chai" menu.md
git log --oneline -2
