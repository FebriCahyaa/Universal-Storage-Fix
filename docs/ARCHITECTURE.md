# Architecture

The module boot service invokes a bounded diagnostic scan. `action.sh` exposes a fixed allowlist, not shell interpolation. `lib/usf.sh` owns diagnostics, audit logging, previews, mutation, verification, and rollback. State is private to `/data/adb/universal_storage_fix`.

`native/` contains portable C++ policy and classification code. `native/zygisk` is an opt-in adapter only and compiles only with verified Magisk headers. `integration/metamodule` is a capability boundary, not a claim of compatibility.

The WebUI is static. It can call only a host-provided `window.usfBridge.request` restricted interface; it has no server, socket, or arbitrary command function.
