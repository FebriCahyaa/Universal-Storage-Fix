# Update system

`update.json` is schema-validated and records API/ABI compatibility, artifacts, hashes, migration and breaking-change flags. An artifact with a missing or mismatched checksum must not be installed. Downgrades and remote scripts are not implemented; no unverified update is applied.

## Dependency automation

Dependabot checks the only present supported ecosystem, GitHub Actions, every Monday at 05:00 UTC and groups patch/minor action updates. Security updates are not disabled. Gradle, npm/Vue, Docker, Android SDK/NDK, and lockfile workflows are intentionally absent until real manifests exist.

Dependabot PRs receive full module validation (YAML, shell, native build/tests, module package, and SHA-256 verification), source-policy review, GitHub dependency review, and CodeQL/security checks. Failed or unavailable mandatory checks block merging and releases. `report-updates.sh` makes terminal, Markdown, or JSON reports without network access.

Auto-merge is disabled. Branch protection and required-check policy have not been independently established for safe auto-merge. Review patch/minor action PRs manually; always manually review major upgrades, privileged paths, release/signing, installation code, storage fixes, native/Zygisk code, or privilege-boundary changes. Notifications use the existing Telegram script and only send when credentials and `USF_NOTIFICATIONS_ENABLED=1` are present.
