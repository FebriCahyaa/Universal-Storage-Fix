# Compatibility

| State | Android API | Meaning |
|---|---:|---|
| BUILD_COMPATIBLE | 34–37 | Native policy accepts these API levels. |
| RUNTIME_VALIDATED | none yet | Requires a rooted device/emulator. |
| EXPERIMENTAL | Zygisk | Requires verified headers and arm64 device tests. |
| UNSUPPORTED | below 34 | Reported, never auto-fixed. |

API-sensitive Android storage operations require an app context. This shell module therefore does not assert MediaStore insertion, query, SAF URI persistence, or app-private directory ownership checks for other apps.
