# Upstream dependencies

The runtime shell implementation depends only on Android toolbox/toybox
utilities supplied by the device. Native Zygisk support is intentionally not
compiled unless the Magisk Zygisk API headers are supplied by a verified build
environment. No private Android, OEM, or platform signing material is used.
