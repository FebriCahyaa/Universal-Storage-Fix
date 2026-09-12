#!/system/bin/sh
# Universal Storage Fix runtime library. POSIX shell for Android toybox.
USF_VERSION=0.1.0
USF_MODDIR=${MODDIR:-${0%/*}}
USF_STATE=${USF_STATE:-/data/adb/universal_storage_fix}
USF_CONFIG="$USF_STATE/config.conf"
USF_DIAGNOSTICS="$USF_STATE/diagnostics.json"
USF_AUDIT="$USF_STATE/audit.log"
USF_BACKUP="$USF_STATE/backup"
USF_LOCK="$USF_STATE/.lock"

usf_log() { mkdir -p "$USF_STATE"; printf '%s [%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" >> "$USF_AUDIT"; }
usf_json() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\r/ /g; s/\n/ /g'; }
usf_api() { getprop ro.build.version.sdk 2>/dev/null || echo 0; }
usf_root() { [ "$(id -u 2>/dev/null)" = 0 ]; }
usf_enabled() { [ ! -f "$USF_STATE/disabled" ]; }
usf_init() {
  umask 077
  mkdir -p "$USF_STATE" "$USF_BACKUP" || return 1
  chmod 700 "$USF_STATE" "$USF_BACKUP" 2>/dev/null || true
  if [ ! -f "$USF_CONFIG" ]; then
    printf '%s\n' 'enabled=true' 'log_level=INFO' 'zygisk_mode=off' 'package_scope=' 'update_channel=stable' > "$USF_CONFIG"
    chmod 600 "$USF_CONFIG"
  fi
}
usf_lock() { mkdir "$USF_LOCK" 2>/dev/null; }
usf_unlock() { rmdir "$USF_LOCK" 2>/dev/null || true; }
usf_volume_json() {
  mountpoint=$1
  if [ -d "$mountpoint" ]; then
    line=$(df -k "$mountpoint" 2>/dev/null | tail -n 1)
    set -- $line
    total=${2:-0}; free=${4:-0}; flags=read_write
    [ -w "$mountpoint" ] || flags=read_only
    printf '{"path":"%s","present":true,"writable":%s,"total_kib":%s,"available_kib":%s,"access":"%s"}' \
      "$(usf_json "$mountpoint")" "$([ "$flags" = read_write ] && echo true || echo false)" "$total" "$free" "$flags"
  else
    printf '{"path":"%s","present":false,"writable":false,"total_kib":0,"available_kib":0,"access":"missing"}' "$(usf_json "$mountpoint")"
  fi
}
usf_issue() { printf '%s' "$1" >> "$USF_ISSUES"; }
usf_collect_diagnostics() {
  [ "${USF_LOCK_HELD:-0}" = 1 ] || usf_lock || { echo 'ERROR: diagnostic operation already running' >&2; return 75; }
  trap 'usf_unlock' EXIT INT TERM
  tmp="$USF_STATE/.diagnostics.$$"; USF_ISSUES="$USF_STATE/.issues.$$"; : > "$USF_ISSUES"
  api=$(usf_api); abi=$(getprop ro.product.cpu.abi 2>/dev/null); model=$(getprop ro.product.model 2>/dev/null)
  manufacturer=$(getprop ro.product.manufacturer 2>/dev/null); kernel=$(uname -r 2>/dev/null)
  zygisk=false; [ -f /data/adb/zygisksu/bin/zygiskd ] || [ -d /data/adb/modules/zygisk ]; z=$?
  [ "$z" = 0 ] && zygisk=true
  [ "$api" -lt 34 ] && usf_issue '{"id":"api_below_target","class":"UNSUPPORTED","severity":"medium","message":"Android API is below the documented target."},'
  [ ! -d /storage/emulated/0 ] && usf_issue '{"id":"shared_storage_missing","class":"REQUIRES_USER_ACTION","severity":"medium","message":"Shared-storage mount is unavailable."},'
  [ -f "$USF_STATE/disabled" ] && usf_issue '{"id":"module_disabled","class":"INFORMATIONAL","severity":"low","message":"Module is disabled by user choice."},'
  issues=$(sed '$ s/,$//' "$USF_ISSUES")
  cat > "$tmp" <<EOF
{"schema_version":1,"generated_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","runtime":{"module_version":"$USF_VERSION","android_api":${api:-0},"model":"$(usf_json "$model")","manufacturer":"$(usf_json "$manufacturer")","abi":"$(usf_json "$abi")","kernel":"$(usf_json "$kernel")","root":$(usf_root && echo true || echo false),"zygisk_detected":$zygisk,"metamodule":"unsupported_no_selected_interface"},"storage":{"internal":$(usf_volume_json /data),"shared":$(usf_volume_json /storage/emulated/0),"external":$(usf_volume_json /sdcard),"mount_namespace":"$(readlink /proc/self/ns/mnt 2>/dev/null || echo unavailable)"},"app_storage":{"module_state":{"path":"$USF_STATE","present":$([ -d "$USF_STATE" ] && echo true || echo false),"writable":$([ -w "$USF_STATE" ] && echo true || echo false)}},"shared_access":{"mediastore":"requires_app_context","saf":"requires_user_granted_uri"},"issues":[${issues}]}
EOF
  mv -f "$tmp" "$USF_DIAGNOSTICS"; chmod 600 "$USF_DIAGNOSTICS"; rm -f "$USF_ISSUES"
  usf_log INFO "diagnostics collected"; cat "$USF_DIAGNOSTICS"
}
usf_print_status() { [ -f "$USF_DIAGNOSTICS" ] || usf_collect_diagnostics >/dev/null; cat "$USF_DIAGNOSTICS"; }
usf_valid_fix() { case "$1" in repair_state|clean_temp|rebuild_cache|refresh_diagnostics) return 0;; *) return 1;; esac; }
usf_preview_fix() {
  usf_valid_fix "$1" || { echo 'ERROR: unknown or unsafe fix' >&2; return 64; }
  case "$1" in
    repair_state) echo '{"id":"repair_state","risk":"low","requires_root":true,"changes":["create and permission module-owned state directories","validate module config"],"rollback":"restores prior module config backup"}' ;;
    clean_temp) echo '{"id":"clean_temp","risk":"low","requires_root":true,"changes":["remove only module-owned .tmp files"],"rollback":"not applicable; temporary files only"}' ;;
    rebuild_cache) echo '{"id":"rebuild_cache","risk":"low","requires_root":true,"changes":["remove module-owned diagnostics cache","rescan"],"rollback":"new cache is generated"}' ;;
    refresh_diagnostics) echo '{"id":"refresh_diagnostics","risk":"none","requires_root":false,"changes":["collect fresh read-only diagnostics"],"rollback":"not applicable"}' ;;
  esac
}
usf_backup_config() { cp -p "$USF_CONFIG" "$USF_BACKUP/config.$(date -u +%Y%m%dT%H%M%SZ).conf"; }
usf_apply_fix() {
  fix=$1; confirm=$2; usf_valid_fix "$fix" || { echo 'ERROR: unknown or unsafe fix' >&2; return 64; }
  [ "$fix" = refresh_diagnostics ] || [ "$confirm" = YES ] || { echo 'ERROR: set USF_CONFIRM=YES after preview' >&2; return 77; }
  usf_lock || return 75; trap 'usf_unlock' EXIT INT TERM
  case "$fix" in
    repair_state) usf_backup_config; mkdir -p "$USF_STATE" "$USF_BACKUP"; chmod 700 "$USF_STATE" "$USF_BACKUP"; chmod 600 "$USF_CONFIG" ;;
    clean_temp) find "$USF_STATE" -xdev -type f -name '*.tmp' -delete 2>/dev/null || true ;;
    rebuild_cache) rm -f "$USF_DIAGNOSTICS"; USF_LOCK_HELD=1 usf_collect_diagnostics || return $? ;;
    refresh_diagnostics) USF_LOCK_HELD=1 usf_collect_diagnostics || return $? ;;
  esac
  usf_log INFO "applied fix=$fix"; usf_verify_fix "$fix"
}
usf_verify_fix() {
  case "$1" in
    repair_state) [ -d "$USF_STATE" ] && [ -f "$USF_CONFIG" ] && [ -r "$USF_CONFIG" ] ;;
    clean_temp) ! find "$USF_STATE" -xdev -type f -name '*.tmp' -print -quit 2>/dev/null | grep -q . ;;
    rebuild_cache|refresh_diagnostics) USF_LOCK_HELD=1 usf_collect_diagnostics >/dev/null && [ -s "$USF_DIAGNOSTICS" ] ;;
    *) echo 'ERROR: unknown fix' >&2; return 64;;
  esac
  rc=$?; [ "$rc" = 0 ] && { echo '{"verified":true}'; usf_log INFO "verified fix=$1"; } || echo '{"verified":false}'
  return "$rc"
}
usf_rollback_fix() {
  [ "$2" = YES ] || { echo 'ERROR: set USF_CONFIRM=YES to roll back' >&2; return 77; }
  case "$1" in
    repair_state) latest=$(ls -1t "$USF_BACKUP"/config.*.conf 2>/dev/null | head -n 1); [ -n "$latest" ] || { echo 'ERROR: no config backup' >&2; return 66; }; cp -p "$latest" "$USF_CONFIG" ;;
    *) echo 'ERROR: selected fix has no reversible state' >&2; return 64;;
  esac
  usf_log INFO "rolled back fix=$1"; echo '{"rolled_back":true}'
}
usf_disable() { [ "$1" = YES ] || { echo 'ERROR: set USF_CONFIRM=YES to disable' >&2; return 77; }; : > "$USF_STATE/disabled"; usf_log WARN 'module disabled'; echo '{"disabled":true}'; }
