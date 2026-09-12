# Zygisk

The adapter is disabled by default and has no hooks. It uses only documented `ModuleBase` lifecycle methods when built against supplied, verified Magisk headers. Build with `-DUSF_ENABLE_ZYGISK=ON -DZYGISK_HEADER_DIR=...`; missing headers fail the build. Package scoping and device validation are prerequisites to enabling injection.
