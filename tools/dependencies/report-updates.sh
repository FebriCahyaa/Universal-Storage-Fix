#!/usr/bin/env sh
# Report only supplied CI metadata; this script never contacts a network.
set -eu
format=${1:---format=terminal}
case "$format" in --format=terminal|--format=markdown|--format=json) ;; *) echo 'Usage: report-updates.sh [--format=terminal|--format=markdown|--format=json]' >&2; exit 64;; esac
name=${USF_DEPENDENCY_NAME:-unavailable}
old=${USF_DEPENDENCY_OLD_VERSION:-unavailable}
new=${USF_DEPENDENCY_NEW_VERSION:-unavailable}
type=${USF_DEPENDENCY_UPDATE_TYPE:-unknown}
ecosystem=${USF_DEPENDENCY_ECOSYSTEM:-unknown}
advisory=${USF_SECURITY_ADVISORY:-none-reported}
compat=${USF_COMPATIBILITY_STATUS:-not-validated}
build=${USF_BUILD_STATUS:-not-run}
test=${USF_TEST_STATUS:-not-run}
merge=${USF_MERGE_STATUS:-manual-review-required}
impact=${USF_RELEASE_IMPACT:-not-assessed}
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
case "$format" in
  --format=terminal)
    printf 'Dependency update report\nname: %s\nold: %s\nnew: %s\ntype: %s\necosystem: %s\nadvisory: %s\ncompatibility: %s\nbuild: %s\ntest: %s\nmerge: %s\nrelease impact: %s\n' "$name" "$old" "$new" "$type" "$ecosystem" "$advisory" "$compat" "$build" "$test" "$merge" "$impact" ;;
  --format=markdown)
    printf '## Dependency update report\n\n| Field | Value |\n|---|---|\n'
    for line in "Dependency|$name" "Old version|$old" "New version|$new" "Type|$type" "Ecosystem|$ecosystem" "Security advisory|$advisory" "Compatibility|$compat" "Build|$build" "Tests|$test" "Merge|$merge" "Release impact|$impact"; do printf '| %s | %s |\n' "${line%%|*}" "${line#*|}"; done ;;
  --format=json)
    printf '{"dependency":"%s","old_version":"%s","new_version":"%s","update_type":"%s","ecosystem":"%s","security_advisory":"%s","compatibility":"%s","build":"%s","test":"%s","merge":"%s","release_impact":"%s"}\n' "$(esc "$name")" "$(esc "$old")" "$(esc "$new")" "$(esc "$type")" "$(esc "$ecosystem")" "$(esc "$advisory")" "$(esc "$compat")" "$(esc "$build")" "$(esc "$test")" "$(esc "$merge")" "$(esc "$impact")" ;;
esac
