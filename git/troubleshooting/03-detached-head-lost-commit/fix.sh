#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/03-detached-head-lost-commit/cafe" || exit 1
h=$(git reflog --format='%h %gs' | grep 'Add secret recipe note' | head -1 | cut -d' ' -f1)
git branch secret-recipe "$h"
git merge -q --no-edit secret-recipe
ok "rescued $h onto branch secret-recipe and merged it"
git log --oneline --graph -4
