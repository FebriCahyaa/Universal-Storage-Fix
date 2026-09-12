#!/usr/bin/env sh
set -eu
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT
USF_STATE="$root/state"; export USF_STATE
. module/lib/usf.sh
usf_init
usf_preview_fix repair_state | grep -q repair_state
if usf_preview_fix arbitrary; then exit 1; fi
if usf_apply_fix repair_state ''; then exit 1; fi
usf_apply_fix repair_state YES | grep -q verified
touch "$USF_STATE/stale.tmp"
usf_apply_fix clean_temp YES | grep -q verified
[ ! -e "$USF_STATE/stale.tmp" ]
node tools/validate-update.mjs update.json >/dev/null
echo 'shell tests passed'
