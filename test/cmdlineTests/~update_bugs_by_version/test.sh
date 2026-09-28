#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/common.sh
source "${REPO_ROOT}/scripts/common.sh"

SOLTMPDIR=$(mktemp -d -t "cmdline-test-update-bugs-by-version-XXXXXX")

cp "${REPO_ROOT}/docs/bugs.yaml" "${SOLTMPDIR}/original_bugs.yaml"
cp "${REPO_ROOT}/docs/bugs.json" "${SOLTMPDIR}/original_bugs.json"
cp "${REPO_ROOT}/docs/bugs_by_version.json" "${SOLTMPDIR}/original_bugs_by_version.json"
"${REPO_ROOT}/scripts/update_bugs_by_version.py"

if ! {
    diff --unified "${SOLTMPDIR}/original_bugs.yaml" "${REPO_ROOT}/docs/bugs.yaml" &&
    diff --unified "${SOLTMPDIR}/original_bugs.json" "${REPO_ROOT}/docs/bugs.json" &&
    diff --unified "${SOLTMPDIR}/original_bugs_by_version.json" "${REPO_ROOT}/docs/bugs_by_version.json"
}
then
    fail "The bug lists were out of date and have been updated. Please investigate and submit a bugfix if necessary."
fi

rm -r "$SOLTMPDIR"
