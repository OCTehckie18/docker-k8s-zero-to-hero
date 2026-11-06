#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/02-push-rejected/you" || exit 1
git pull -q --rebase
git push -q
ok "rebased on Asha's commit and pushed"
git log --oneline --graph -4
