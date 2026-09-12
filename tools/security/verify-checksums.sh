#!/usr/bin/env sh
set -eu
manifest=${1:?Usage: verify-checksums.sh SHA256SUMS}
[ -f "$manifest" ] || { echo "missing manifest: $manifest" >&2; exit 66; }
dir=$(dirname "$manifest")
[ -s "$manifest" ] || { echo 'empty checksum manifest' >&2; exit 65; }
(cd "$dir" && sha256sum -c "$(basename "$manifest")")
echo 'checksum verification passed'
