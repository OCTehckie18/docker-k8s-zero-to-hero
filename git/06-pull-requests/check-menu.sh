#!/usr/bin/env bash
# A tiny "CI check" for the café repo: every price must be between ₹10 and ₹1000.
# Runs on your laptop (G06) and, in real life, on every pull request (see ci-example.yml).
#
#   ./check-menu.sh [file...]      # default: every *.md file in the current folder
set -uo pipefail

files=("$@")
[ ${#files[@]} -gt 0 ] || files=(*.md)

fail=0
for f in "${files[@]}"; do
  [ -f "$f" ] || continue
  while IFS= read -r line; do
    price=$(printf '%s' "$line" | sed -n 's/.*₹\([0-9][0-9]*\).*/\1/p')
    [ -n "$price" ] || continue
    if [ "$price" -lt 10 ] || [ "$price" -gt 1000 ]; then
      echo "❌ $f: suspicious price ₹$price  →  $line"
      fail=1
    fi
  done < "$f"
done

if [ "$fail" -eq 0 ]; then
  echo "✅ menu check passed: all prices look sane"
else
  echo "🚫 menu check FAILED: fix the prices above before merging"
fi
exit "$fail"
