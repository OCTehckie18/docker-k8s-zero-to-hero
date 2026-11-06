#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 03-detached-head-lost-commit
git switch -q --detach HEAD~1
printf '\n<!-- secret recipe: 2 cardamom pods per chai -->\n' >> menu.md
git commit -qam "Add secret recipe note"
say "Committed in detached HEAD, now switching back to main…"
git switch main 2>&1 | head -4
git log --oneline
