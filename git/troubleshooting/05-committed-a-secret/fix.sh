#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
cd "$T/05-committed-a-secret/cafe" || exit 1
git rm -q --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -q --amend --no-edit
git log -p | grep API_KEY || ok "secret is gone from history"
git show --stat --oneline HEAD
