#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/04-merge-conflict/cafe" || exit 1
sed -i.bak '/^<<<<<<< /,/^>>>>>>> /c\
| Filter Coffee | ₹70 |
' menu.md && rm menu.md.bak
git add menu.md
git commit -q --no-edit
ok "conflict resolved with the agreed price"
grep "Filter Coffee" menu.md; git log --oneline --graph -4
