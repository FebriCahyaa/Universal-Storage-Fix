#!/system/bin/sh
# Restricted command interface. This script accepts fixed operations only.
MODDIR=${0%/*}
. "$MODDIR/lib/usf.sh"
usf_init

op=${1:-scan}
case "$op" in
  scan) usf_collect_diagnostics ;;
  status) usf_print_status ;;
  preview) usf_preview_fix "${2:-}" ;;
  apply) usf_apply_fix "${2:-}" "${USF_CONFIRM:-}" ;;
  verify) usf_verify_fix "${2:-}" ;;
  rollback) usf_rollback_fix "${2:-}" "${USF_CONFIRM:-}" ;;
  disable) usf_disable "${USF_CONFIRM:-}" ;;
  *) echo "ERROR: unsupported operation" >&2; exit 64 ;;
esac
