# Releases

Tag releases run tests, packaging, and checksum verification before `gh release create`. The release contains the ZIP and SHA256SUMS. Add `update.json` and cryptographic signatures only after artifact URLs and signing identity are real. Telegram delivery is optional and skips safely when secrets are absent.
