#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(dirname "$0")"/..
# shellcheck source=scripts/common.sh
source "${REPO_ROOT}/scripts/common.sh"

cd "$REPO_ROOT"
version=$(scripts/get_version.sh)
commit_hash=$(git rev-parse --short=8 HEAD)

if [[ -e prerelease.txt ]]; then
    prerelease_suffix=$(cat prerelease.txt)
    if [[ $prerelease_suffix == "" ]]; then
        # File exists and has zero size -> not a prerelease
        version_string="$version"
    elif [[ $prerelease_suffix == pre.* ]]; then
        # Tagged prerelease -> unambiguous, so commit hash not needed
        version_string="${version}-${prerelease_suffix}"
    else
        # Nightly/develop/other prerelease -> include commit hash
        version_string="${version}-${prerelease_suffix}-${commit_hash}"
    fi
else
    # Nightly/develop/other prerelease -> include commit hash + default prerelease suffix
    commit_date=$(TZ=UTC git show --quiet --date="format-local:%Y.%-m.%-d" --format="%cd")
    version_string="${version}-nightly-${commit_date}-${commit_hash}"
fi

# The only purpose of commit_hash.txt is to make it possible to build the compiler without git.
# It is not meant as an override of the real hash.
[[ ! -e commit_hash.txt ]] || \
    fail "commit_hash.txt is present in the repository root, but will not be used to override the commit hash for the source package."

TEMPDIR=$(mktemp -d -t "solc-src-tarball-XXXXXX")
SOLDIR="${TEMPDIR}/solidity_${version_string}/"
mkdir "$SOLDIR"

# Ensure that submodules are initialized.
git submodule update --init --recursive
# Store the current source
git checkout-index --all --prefix="$SOLDIR"
# shellcheck disable=SC2016
SOLDIR="$SOLDIR" git submodule foreach 'git checkout-index --all --prefix="${SOLDIR}/${sm_path}/"'

# Documentation is pretty heavy and not necessary to build the compiler.
# Especially nlohmann-json has several huge images, which blow up the size of the compressed tarball.
# shellcheck disable=SC2016
SOLDIR="$SOLDIR" git submodule foreach 'rm -rf "${SOLDIR}/${sm_path}/"doc/; rm -rf "${SOLDIR}/${sm_path}/"docs/'

# Include the commit hash and prerelease suffix in the tarball
echo "$commit_hash" > "${SOLDIR}/commit_hash.txt"
[[ -e prerelease.txt ]] && cp prerelease.txt "${SOLDIR}/"

mkdir -p "$REPO_ROOT/upload"
tar \
    --owner 0 \
    --group 0 \
    --create \
    --gzip \
    --file "${REPO_ROOT}/upload/solidity_${version_string}.tar.gz" \
    --directory "$TEMPDIR" \
    "solidity_${version_string}"
rm -r "$TEMPDIR"
