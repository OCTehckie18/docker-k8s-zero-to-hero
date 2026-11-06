#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/01-committed-on-main/you" || exit 1
git branch feature/loyalty-card
git reset -q --hard origin/main
git switch -q feature/loyalty-card
git push -q -u origin feature/loyalty-card
ok "commits moved to feature/loyalty-card; main matches origin again"
git log --oneline --graph --all
