#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
team 07-pull-blocked-local-changes
cd ../asha || exit 1
sed -i.bak 's/Filter Coffee | ₹80/Filter Coffee | ₹85/' menu.md && rm menu.md.bak
as "Asha (Lead Dev)" asha@beanbyte.cafe commit -qam "Urgent: filter coffee ₹85"
git push -q
cd ../you || exit 1
sed -i.bak 's/Espresso | ₹130/Espresso | ₹135/' menu.md && rm menu.md.bak
say "You have unfinished edits to menu.md. Now pulling Asha's urgent fix…"
git pull
