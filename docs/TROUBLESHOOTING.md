# Troubleshooting

Run `action.sh scan` and inspect the private audit log as root. A missing shared-storage mount or read-only volume is reported for user/OEM action; this module will not remount or repair it globally. If diagnostics are stale, preview and apply `refresh_diagnostics`. If the module is disruptive, disable it with explicit confirmation or uninstall through Magisk.
