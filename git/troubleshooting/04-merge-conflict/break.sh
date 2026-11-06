#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 04-merge-conflict
git switch -q -c chai-price
sed -i.bak 's/Masala Chai | ₹60/Masala Chai | ₹75/' menu.md && rm menu.md.bak
git commit -qam "Chai ₹75"
git switch -q main
sed -i.bak 's/Masala Chai | ₹60/Masala Chai | ₹65/' menu.md && rm menu.md.bak
git commit -qam "Chai ₹65"
say "Merging chai-price into main…"
git merge chai-price
