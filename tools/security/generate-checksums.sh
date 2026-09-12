#!/usr/bin/env sh
set -eu
dir=${1:?Usage: generate-checksums.sh ARTIFACT_DIRECTORY}
[ -d "$dir" ] || { echo "missing directory: $dir" >&2; exit 66; }
out="$dir/SHA256SUMS"; tmp="$dir/.SHA256SUMS.$$"
find "$dir" -maxdepth 1 -type f ! -name SHA256SUMS ! -name '.SHA256SUMS.*' -printf '%f\n' | LC_ALL=C sort | while IFS= read -r name; do
  [ -n "$name" ] || continue
  (cd "$dir" && sha256sum "$name")
done > "$tmp"
[ -s "$tmp" ] || { rm -f "$tmp"; echo 'no artifacts to hash' >&2; exit 65; }
mv -f "$tmp" "$out"; echo "generated $out"
