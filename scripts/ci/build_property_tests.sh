#!/usr/bin/env bash
set -ex

ROOTDIR="$(realpath "$(dirname "$0")/../..")"
BUILDDIR="${ROOTDIR}/build"
mkdir -p "${BUILDDIR}" && mkdir -p "$BUILDDIR/deps"

cd "${BUILDDIR}"
export CCACHE_DIR="$HOME/.ccache"
export CCACHE_BASEDIR="$ROOTDIR"
export CCACHE_NOHASHDIR=1
CMAKE_OPTIONS="${CMAKE_OPTIONS:-} -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
mkdir -p "$CCACHE_DIR"

# PROPERTY_BASED_TESTS_MODE defaults to "unittest", which runs each FUZZ_TEST as a regular
# GoogleTest case. Fuzzing mode is intentionally not used here.
# shellcheck disable=SC2086
cmake .. -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}" \
  -DPROPERTY_BASED_TESTS=ON \
  $CMAKE_OPTIONS

ccache -z
# Build only the property-test executables, not the whole project.
cmake --build . --target property_tests
ccache -s
