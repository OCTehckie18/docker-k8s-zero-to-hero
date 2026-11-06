#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 08-who-broke-it-bisect
git tag v1.0
i=0
for item in "Cold Brew|180" "Veg Puff|45" "Brownie|110" "Iced Tea|90" "Lemonade|80" "BUG" "Muffin|70" "Cookie|50" "Bagel|95" "Smoothie|160"; do
  i=$((i+1))
  if [ "$item" = BUG ]; then
    sed -i.bak 's/Masala Chai | ₹60/Masala Chai | ₹600/' menu.md && rm menu.md.bak
    git commit -qam "style: tidy menu spacing"
  else
    printf '| %s | ₹%s |\n' "${item%%|*}" "${item##*|}" >> menu.md
    git commit -qam "feat: add ${item%%|*}"
  fi
done
grep "Masala Chai" menu.md
git log --oneline v1.0..main
