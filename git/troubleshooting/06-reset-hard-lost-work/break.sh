#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 06-reset-hard-lost-work
for row in "Cold Coffee|180" "Maddur Vada|45" "Mysore Pak|110"; do
  printf '| %s | ₹%s |\n' "${row%%|*}" "${row##*|}" >> menu.md
  git commit -qam "Add ${row%%|*}"
done
git log --oneline -4
say "Running: git reset --hard HEAD~3 …"
git reset --hard HEAD~3
git log --oneline
