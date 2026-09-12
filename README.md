# Universal Storage Fix

Safety-first Magisk storage diagnostics and reversible remediation for Android API 34–37. It does not remount partitions, change global storage ownership, modify SELinux, delete user data, or bypass scoped-storage permissions.

## What works

- Collects mount, capacity, writeability, module-state, kernel, ABI, root, and Zygisk-presence facts.
- Classifies missing/read-only volumes and unsupported API levels without automatically changing them.
- Repairs only `/data/adb/universal_storage_fix` state; every mutation has a fixed ID and confirmation gate.
- Packages a standard Magisk module and generates deterministic SHA-256 manifests.

## Install and use

Install the generated ZIP from Magisk, reboot, then run `su -c /data/adb/modules/universal_storage_fix/action.sh scan`. Use `preview FIX`, then `USF_CONFIRM=YES action.sh apply FIX`. Available fixes are `repair_state`, `clean_temp`, `rebuild_cache`, and `refresh_diagnostics`.

## Important limitations

MediaStore and SAF require an Android app context and user-granted URI permissions; the module reports this rather than faking access. No physical Android device, Android SDK, NDK, or verified Zygisk header set was available for this initial build, so arm64 Android and Zygisk builds are not runtime-validated.

## Build

`make test package checksums` builds host-native tests and the installable ZIP. `make verify` also checks the manifest and release metadata. SHA-256 detects modification, not release identity; use a signed GitHub release when signatures are introduced.

## Dependency updates

Dependabot maintains GitHub Actions weekly. No Gradle, Android, npm/Vue, Docker, or lockfile manifests exist, so those ecosystems are not configured. Dependabot updates are validated but never auto-merged; see [dependency policy](docs/DEPENDENCY_POLICY.md) and [update system](docs/UPDATE_SYSTEM.md).

See `docs/` for architecture, compatibility, security, installation, update, test, and release details.
