#!/usr/bin/env sh
set -eu
escape_html() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'; }
status=${1:-unknown}; version=${USF_VERSION:-unknown}; build=${USF_BUILD:-unknown}
branch=${GITHUB_REF_NAME:-$(git branch --show-current 2>/dev/null || echo unknown)}
commit=${GITHUB_SHA:-$(git rev-parse --short HEAD 2>/dev/null || echo unknown)}
msg="<b>Universal Storage Fix</b>
Status: $(escape_html "$status")
Version: $(escape_html "$version") ($build)
Branch: $(escape_html "$branch")
Commit: $(escape_html "$commit")
ABI: arm64-v8a; Android: API 34-37"
if [ "${DRY_RUN:-0}" = 1 ]; then printf '%s\n' "$msg"; exit 0; fi
[ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ] || { echo 'Telegram credentials absent; notification skipped.' >&2; exit 0; }
response=$(curl --fail --silent --show-error --max-time 15 -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" --data-urlencode "parse_mode=HTML" --data-urlencode "text=$msg") || { echo 'Telegram API request failed' >&2; exit 1; }
printf '%s' "$response" | grep -q '"ok":true' || { echo 'Telegram rejected notification' >&2; exit 1; }
echo 'Telegram notification sent.'
