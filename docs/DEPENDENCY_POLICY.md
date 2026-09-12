# Dependency policy

The repository currently uses GitHub Actions and CMake only. Dependabot is therefore configured only for `github-actions`; there are no Gradle, Android, npm/Vue, Docker, or lockfile manifests to update. Adding a manifest requires extending this policy and the validation workflow before enabling its Dependabot ecosystem.

## Schedule and grouping

Action updates run weekly on Monday at 05:00 UTC, with a limit of five open PRs. Patch and minor action updates are grouped. Dependabot security updates remain enabled by GitHub independently of the version-update schedule. Major upgrades must be reviewed separately.

## Review and merge

Every Dependabot PR runs YAML, shell, native-test, package, checksum, source-policy, and applicable dependency-review checks. Auto-merge is disabled. The policy workflow refuses privileged/release-sensitive paths and major updates; enabling merge later requires verified branch protection, required checks, Dependabot permissions, and an explicit repository-policy decision.

## Source and locking rules

Only documented registries and official GitHub Actions are allowed. New third-party actions should be immutable-SHA pinned after source review. Existing official actions use maintained major tags and are updated by Dependabot. Dynamic Gradle versions, arbitrary remote scripts, unreviewed native prebuilts, registry changes, and lockfile changes without their manifest are rejected or manually reviewed.

## Platform policy

Android/Gradle compatibility, arm64, Zygisk, and WebUI privilege boundaries cannot be established by an action-only update. Any future dependency change in those areas needs device compatibility evidence, migration notes, rollback review, and documentation. The native build uses CMake and no downloaded libraries.

## Operations

Run **Actions → Dependency update validation** manually to validate the current tree. Use `tools/dependencies/report-updates.sh --format=markdown` for an offline report. Telegram notifications reuse `notify-build.sh`; credentials are optional and never printed. A failed update is left unmerged; revert its PR or pin a proven compatible version after review.
