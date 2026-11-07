#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/07-pull-blocked-local-changes/you" || exit 1
git stash -q
git pull -q
git stash pop -q
ok "pulled Lakshmi's fix and restored your edits"
grep -E "Benne Dosa|Idli Vada" menu.md
