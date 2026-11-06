#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 06-reset-hard-lost-work
for row in "Cold Brew|180" "Veg Puff|45" "Brownie|110"; do
  printf '| %s | ₹%s |\n' "${row%%|*}" "${row##*|}" >> menu.md
  git commit -qam "Add ${row%%|*}"
done
git log --oneline -4
say "Running: git reset --hard HEAD~3 …"
git reset --hard HEAD~3
git log --oneline
