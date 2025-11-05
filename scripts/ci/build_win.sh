#!/usr/bin/env bash
set -euo pipefail

(( $# <= 1 )) || { >&2 echo "Usage: $0 [PRERELEASE_SOURCE]"; exit 1; }
prerelease_source="${1:-ci}"
ROOTDIR="$(realpath "$(dirname "$0")/../../")"
FORCE_RELEASE="${FORCE_RELEASE:-}"
CIRCLE_TAG="${CIRCLE_TAG:-}"

cd "$ROOTDIR"
"${ROOTDIR}/scripts/prerelease_suffix.sh" "$prerelease_source" "$CIRCLE_TAG" > prerelease.txt

mkdir -p build/
cd build/

# NOTE: Using an array to force Bash to do wildcard expansion
boost_dir=("${ROOTDIR}/deps/boost/lib/cmake/Boost-"*)

"${ROOTDIR}/deps/cmake/bin/cmake" \
    -G "Visual Studio 16 2019" \
    -DBoost_DIR="${boost_dir[*]}" \
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded \
    -DCMAKE_INSTALL_PREFIX="${ROOTDIR}/uploads/" \
    ..
MSBuild.exe solidity.sln \
    -property:Configuration=Release \
    -maxCpuCount:10 \
    -verbosity:minimal
"${ROOTDIR}/deps/cmake/bin/cmake" \
    --build . \
    -j 10 \
    --target install \
    --config Release
