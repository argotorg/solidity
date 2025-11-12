#!/usr/bin/env bash
set -ex

ROOTDIR="$(dirname "$0")/../.."
# shellcheck source=scripts/common.sh
source "${ROOTDIR}/scripts/common.sh"

cd "${ROOTDIR}"

# Build release version
echo -n >prerelease.txt

mkdir -p build
cd build

# shellcheck disable=SC2086
cmake .. -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}" $CMAKE_OPTIONS -G "Unix Makefiles"

make
