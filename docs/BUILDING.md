# Building

Requirements: CMake, C++17 compiler, zip, sha256sum, Node.js. Run `make test package checksums`. Host builds test policy code only. Android arm64 builds require an installed NDK and should use a separate toolchain file; release signing must use CI secrets, never repository keys.
