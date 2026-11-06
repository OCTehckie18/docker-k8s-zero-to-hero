#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
team 01-committed-on-main
printf '\n## 💳 Loyalty card\nBuy 9 coffees, the 10th is free!\n' >> menu.md
git commit -qam "feat: add loyalty card section"
printf 'Ask staff for your card.\n' >> menu.md
git commit -qam "feat: explain how to get a loyalty card"
say "You made two commits for the loyalty feature, on main…"
git status -sb | head -1
git log --oneline --graph --all
