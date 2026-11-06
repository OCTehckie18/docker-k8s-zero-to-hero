#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 03-detached-head-lost-commit
git checkout -q HEAD~1
printf '\n<!-- secret recipe: 80:20 coffee-chicory, extra benne on every dosa -->\n' >> menu.md
git commit -qam "Add secret recipe note"
say "Committed in detached HEAD, now switching back to main…"
git checkout main 2>&1 | head -4
git log --oneline
