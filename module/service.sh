#!/system/bin/sh
# Boot service: bounded, module-owned initialization only.
MODDIR=${0%/*}
. "$MODDIR/lib/usf.sh"
usf_init
usf_log INFO "service start"
usf_collect_diagnostics >/dev/null 2>&1 || usf_log WARN "boot diagnostic scan failed"
usf_log INFO "service complete"
