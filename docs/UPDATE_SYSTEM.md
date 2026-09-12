# Update system

`update.json` is schema-validated and records API/ABI compatibility, artifacts, hashes, migration and breaking-change flags. An artifact with a missing or mismatched checksum must not be installed. Downgrades and remote scripts are not implemented; no unverified update is applied.
