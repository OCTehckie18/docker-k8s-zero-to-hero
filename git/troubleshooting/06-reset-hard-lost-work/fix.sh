#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/06-reset-hard-lost-work/cafe" || exit 1
git reset -q --hard 'HEAD@{1}'
ok "restored from the reflog"
git log --oneline -4
