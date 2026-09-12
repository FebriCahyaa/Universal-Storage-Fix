# Installation and recovery

Install the release ZIP through Magisk Manager and reboot. Review a preview before every mutation. To disable module behavior: `su -c 'USF_CONFIRM=YES /data/adb/modules/universal_storage_fix/action.sh disable'`.

Uninstall through Magisk Manager. If recovery is required, remove only the module directory from recovery; do not delete `/data` or shared storage. Module state is isolated under `/data/adb/universal_storage_fix`.
