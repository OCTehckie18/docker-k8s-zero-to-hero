#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
team 07-pull-blocked-local-changes
cd ../lakshmi || exit 1
sed -i.bak 's/Idli Vada | ₹80/Idli Vada | ₹85/' menu.md && rm menu.md.bak
as "Lakshmi (Lead Dev)" lakshmi@vidyarthibhavan.example commit -qam "Urgent: idli vada ₹85"
git push -q
cd ../you || exit 1
sed -i.bak 's/Benne Dosa | ₹130/Benne Dosa | ₹135/' menu.md && rm menu.md.bak
say "You have unfinished edits to menu.md. Now pulling Lakshmi's urgent fix…"
git pull
