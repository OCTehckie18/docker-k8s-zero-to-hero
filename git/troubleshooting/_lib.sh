#!/usr/bin/env bash
# Shared helpers for Git troubleshooting scenarios. Sourced by break.sh / fix.sh.
# Every scenario works in a throwaway sandbox: /tmp/z2h-git-ts/<scenario>
set -uo pipefail
# Ignore personal global settings (signing, pull.rebase, hooks…) so every learner gets the same sandbox.
export GIT_CONFIG_GLOBAL=/dev/null

T="${Z2H_GIT_TS:-/tmp/z2h-git-ts}"
say() { printf '\033[1;36m▶ %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }

as() {  # as "<name>" <email> <git args...>: run git as a given person
  local n=$1 e=$2; shift 2
  GIT_AUTHOR_NAME="$n" GIT_AUTHOR_EMAIL="$e" GIT_COMMITTER_NAME="$n" GIT_COMMITTER_EMAIL="$e" git "$@"
}

menu() {  # menu <benne-dosa> <ghee-roast> <filter-coffee> <idli-vada>
  printf '# 🥞 Vidyarthi Bhavan, Basavanagudi: Menu\n\n| Item | Price |\n|---|---|\n| Benne Dosa | ₹%s |\n| Ghee Roast Dosa | ₹%s |\n| Filter Coffee | ₹%s |\n| Idli Vada | ₹%s |\n' "$1" "$2" "$3" "$4" > menu.md
}

# solo <name>: a single repo at $T/<name>/cafe with two commits
solo() {
  rm -rf "${T:?}/$1"; mkdir -p "$T/$1/cafe"; cd "$T/$1/cafe" || exit 1
  git init -q -b main; git config user.name "You"; git config user.email "you@vidyarthibhavan.example"
  menu 130 150 60 80; git add menu.md; git commit -qm "Add menu"
  printf '# 🕗 Opening hours\n\nMon–Sat: 8 am – 10 pm\n' > hours.md; git add hours.md; git commit -qm "Add opening hours"
}

# team <name>: "GitHub" at $T/<name>/github.git, your clone at .../you, Asha's at .../asha
team() {
  solo "$1"
  git init -q --bare -b main "$T/$1/github.git"
  git remote add origin "$T/$1/github.git"; git push -q -u origin main
  cd "$T/$1" || exit 1; mv cafe you
  git clone -q "$T/$1/github.git" asha
  git -C asha config user.name "Asha (Lead Dev)"; git -C asha config user.email "asha@vidyarthibhavan.example"
  git -C you remote set-url origin "$T/$1/github.git"
  cd "$T/$1/you" || exit 1
}
