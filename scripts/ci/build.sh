#!/usr/bin/env bash
set -ex

ROOTDIR="$(dirname "$0")/../.."
# shellcheck source=scripts/common.sh
source "${ROOTDIR}/scripts/common.sh"

prerelease_source="${1:-ci}"

cd "${ROOTDIR}"

"${ROOTDIR}/scripts/prerelease_suffix.sh" "$prerelease_source" "$CIRCLE_TAG" > prerelease.txt

mkdir -p build
cd build

[[ -n $COVERAGE && -z $CIRCLE_TAG ]] && CMAKE_OPTIONS="$CMAKE_OPTIONS -DCOVERAGE=ON"

# shellcheck disable=SC2086
cmake .. -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}" $CMAKE_OPTIONS

cmake --build .
