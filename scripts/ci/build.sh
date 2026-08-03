#!/usr/bin/env bash
set -ex

ROOTDIR="$(realpath "$(dirname "$0")/../..")"
# shellcheck source=scripts/common.sh
source "${ROOTDIR}/scripts/common.sh"

prerelease_source="${1:-ci}"

cd "${ROOTDIR}"

"${ROOTDIR}/scripts/prerelease_suffix.sh" "$prerelease_source" "$CIRCLE_TAG" > prerelease.txt

mkdir -p build
cd build

[[ -n $COVERAGE && -z $CIRCLE_TAG ]] && CMAKE_OPTIONS="$CMAKE_OPTIONS -DCOVERAGE=ON"

export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
export CCACHE_BASEDIR="$ROOTDIR"
export CCACHE_NOHASHDIR=1
CMAKE_OPTIONS="${CMAKE_OPTIONS:-} -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
mkdir -p "$CCACHE_DIR"

# shellcheck disable=SC2086
cmake .. -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}" $CMAKE_OPTIONS

ccache -z

cmake --build .

ccache -s
