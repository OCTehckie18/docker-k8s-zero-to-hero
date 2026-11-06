#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
team 02-push-rejected
cd ../asha || exit 1
printf '| Cold Brew | ₹180 |\n' >> menu.md
as "Asha (Lead Dev)" asha@beanbyte.cafe commit -qam "Add cold brew"
git push -q
cd ../you || exit 1
sed -i.bak 's/10 pm/10:30 pm/' hours.md && rm hours.md.bak
git commit -qam "Fix closing time"
say "Pushing your fix…"
git push
