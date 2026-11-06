#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 04-merge-conflict
git checkout -q -b coffee-price
sed -i.bak 's/Filter Coffee | ₹60/Filter Coffee | ₹75/' menu.md && rm menu.md.bak
git commit -qam "Coffee ₹75"
git checkout -q main
sed -i.bak 's/Filter Coffee | ₹60/Filter Coffee | ₹65/' menu.md && rm menu.md.bak
git commit -qam "Coffee ₹65"
say "Merging coffee-price into main…"
git merge coffee-price
