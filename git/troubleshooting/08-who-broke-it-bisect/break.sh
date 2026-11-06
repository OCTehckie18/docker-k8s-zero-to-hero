#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 08-who-broke-it-bisect
git tag v1.0
i=0
for item in "Cold Coffee|180" "Maddur Vada|45" "Mysore Pak|110" "Rose Milk|90" "Nimbu Soda|80" "BUG" "Kesari Bath|70" "Khara Bun|50" "Bisi Bele Bath|95" "Holige|160"; do
  i=$((i+1))
  if [ "$item" = BUG ]; then
    sed -i.bak 's/Filter Coffee | ₹60/Filter Coffee | ₹600/' menu.md && rm menu.md.bak
    git commit -qam "style: tidy menu spacing"
  else
    printf '| %s | ₹%s |\n' "${item%%|*}" "${item##*|}" >> menu.md
    git commit -qam "feat: add ${item%%|*}"
  fi
done
grep "Filter Coffee" menu.md
git log --oneline v1.0..main
