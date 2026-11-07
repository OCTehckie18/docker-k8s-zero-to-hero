#!/usr/bin/env bash
# Rebuilds the starting point of any Git lab, so you can start (or restart) anywhere.
#
#   ./git/scripts/lab-start.sh 02      # fresh state for lab G02
#
# Everything lives in ~/z2h-git (override with Z2H_GIT_HOME). The folder is wiped and recreated.
#   ~/z2h-git/cafe          your repository
#   ~/z2h-git/github/       our offline "GitHub" (bare repositories)
#   ~/z2h-git/lakshmi          your teammate Lakshmi's clone (labs G04+)
set -euo pipefail
# Ignore personal global settings (signing, pull.rebase, hooks…) so every learner gets the same start.
export GIT_CONFIG_GLOBAL=/dev/null

W="${Z2H_GIT_HOME:-$HOME/z2h-git}"
LAB="${1:-}"
[ -n "$LAB" ] || { echo "usage: $0 <lab number 02-07>"; exit 1; }

say() { printf '\033[1;36m▶ %s\033[0m\n' "$*"; }

# Commit as a given person, without touching anyone's global Git config.
as() {  # as "<name>" <email> <git args...>
  local n=$1 e=$2; shift 2
  GIT_AUTHOR_NAME="$n" GIT_AUTHOR_EMAIL="$e" GIT_COMMITTER_NAME="$n" GIT_COMMITTER_EMAIL="$e" git "$@"
}
YOU=("You" "you@vidyarthibhavan.example")
LAKSHMI=("Lakshmi (Lead Dev)" "lakshmi@vidyarthibhavan.example")
RAVI=("Ravi (Intern)" "ravi@vidyarthibhavan.example")

write_menu() {  # write_menu <benne-dosa> <ghee-roast> <filter-coffee> <idli-vada> [extra rows...]
  {
    echo "# 🥞 Vidyarthi Bhavan, Basavanagudi: Menu"
    echo
    echo "| Item | Price |"
    echo "|---|---|"
    echo "| Benne Dosa | ₹$1 |"
    echo "| Ghee Roast Dosa | ₹$2 |"
    echo "| Filter Coffee | ₹$3 |"
    echo "| Idli Vada | ₹$4 |"
    shift 4
    for row in "$@"; do echo "$row"; done
  } > menu.md
}

new_repo() {
  rm -rf "$W"; mkdir -p "$W/cafe"; cd "$W/cafe"
  git init -q -b main
  git config user.name "${YOU[0]}"; git config user.email "${YOU[1]}"
}

# End of G01: menu, opening hours, benne dosa raised to ₹130.
state_g01_end() {
  new_repo
  write_menu 120 150 60 80
  git add menu.md && as "${YOU[@]}" commit -q -m "Add menu with 4 items"
  printf '# 🕗 Opening hours\n\nMon–Sat: 8 am – 10 pm\nSunday: 9 am – 6 pm\n' > hours.md
  git add hours.md && as "${YOU[@]}" commit -q -m "Add opening hours"
  write_menu 130 150 60 80
  git commit -qam "Raise benne dosa to ₹130" --author="You <you@vidyarthibhavan.example>"
}

# Start of G02: Ravi the intern "borrowed your laptop" overnight.
state_g02() {
  state_g01_end
  write_menu 130 150 60 80 "| Badam Milk | ₹90 |"
  as "${RAVI[@]}" commit -qam "Add Badam Milk"
  write_menu 1 150 60 80 "| Badam Milk | ₹90 |"
  as "${RAVI[@]}" commit -qam "Tidy up menu formatting"
}

# End of G02 = start of G03: the bad commit reverted, .gitignore added.
state_g03() {
  state_g02
  as "${YOU[@]}" revert --no-edit HEAD >/dev/null
  printf 'secrets.txt\n.env\n' > .gitignore
  git add .gitignore && as "${YOU[@]}" commit -q -m "Ignore secret files"
}

# End of G03 = start of G04: cold coffee merged, hours updated (merge commit).
state_g04() {
  state_g03
  git checkout -q -b add-cold-coffee
  write_menu 130 150 60 80 "| Badam Milk | ₹90 |" "| Cold Coffee | ₹180 |"
  as "${YOU[@]}" commit -qam "Add cold coffee"
  git checkout -q main && git merge -q add-cold-coffee && git branch -q -d add-cold-coffee
  printf '# 📖 Vidyarthi Bhavan website\n\nThe menu and opening hours of our café.\n' > README.md
  git add README.md && as "${YOU[@]}" commit -q -m "Add README"
}

# Start of G05/G06: remote + your clone + Lakshmi's clone, all in sync.
state_team() {
  state_g04
  mkdir -p "$W/github"
  git init -q --bare -b main "$W/github/cafe.git"
  git remote add origin "$W/github/cafe.git"
  git push -q -u origin main
  git clone -q "$W/github/cafe.git" "$W/lakshmi"
  git -C "$W/lakshmi" config user.name "${LAKSHMI[0]}"; git -C "$W/lakshmi" config user.email "${LAKSHMI[1]}"
}

# Start of G07: a release tag, then a week of commits with one hidden bug.
state_g07() {
  state_team
  as "${YOU[@]}" tag -a v1.0.0 -m "Grand opening menu"
  extras=("| Badam Milk | ₹90 |" "| Cold Coffee | ₹180 |")
  write_menu 130 150 60 80 "${extras[@]}" "| Maddur Vada | ₹45 |"
  git add menu.md && as "${LAKSHMI[@]}" commit -q -m "feat: add Maddur Vada"
  printf '# 🕗 Opening hours\n\nMon–Sat: 7 am – 10 pm\nSunday: 9 am – 6 pm\n' > hours.md
  git add hours.md && as "${YOU[@]}" commit -q -m "feat: open at 7 am on weekdays"
  write_menu 130 150 60 8 "${extras[@]}" "| Maddur Vada | ₹45 |"
  git add menu.md && as "${RAVI[@]}" commit -q -m "refactor: align menu table columns"
  printf '# 📖 Vidyarthi Bhavan website\n\nThe menu and opening hours of our café.\nOrder online: coming soon!\n' > README.md
  git add README.md && as "${LAKSHMI[@]}" commit -q -m "docs: mention online ordering"
  write_menu 130 150 60 8 "${extras[@]}" "| Maddur Vada | ₹45 |" "| Mysore Pak | ₹110 |"
  git add menu.md && as "${YOU[@]}" commit -q -m "feat: add Mysore Pak"
  printf '# 🕗 Opening hours\n\nMon–Sat: 7 am – 11 pm\nSunday: 9 am – 6 pm\n' > hours.md
  git add hours.md && as "${LAKSHMI[@]}" commit -q -m "feat: close at 11 pm on weekdays"
  git push -q origin main --tags
  git -C "$W/lakshmi" pull -q --no-rebase
}

case "$LAB" in
  02|2) state_g02 ;;
  03|3) state_g03 ;;
  04|4) state_g04 ;;
  05|5|06|6) state_team ;;
  07|7) state_g07 ;;
  *) echo "Lab $LAB has no start script (G00 and G01 start from nothing)."; exit 1 ;;
esac
say "Lab G$(printf '%02d' "$((10#$LAB))") is ready in $W"
git -C "$W/cafe" log --oneline --graph --decorate -n 8
