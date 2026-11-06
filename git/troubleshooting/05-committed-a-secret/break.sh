#!/usr/bin/env bash
source "$(dirname "$0")/../_lib.sh"
solo 05-committed-a-secret
printf 'PAYMENT_API_KEY=sk_live_51Hx_DO_NOT_SHARE\n' > .env
sed -i.bak 's/Benne Dosa | ₹130/Benne Dosa | ₹140/' menu.md && rm menu.md.bak
git add .
git commit -qm "Raise benne dosa to ₹140"
say "Last commit:"
git show --stat --oneline HEAD
