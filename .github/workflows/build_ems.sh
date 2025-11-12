#!/usr/bin/env bash
set -ev

ROOTDIR="$(dirname "$0")/../.."
# shellcheck source=scripts/common.sh
source "${ROOTDIR}/scripts/common.sh"

cd "${ROOTDIR}"

# Build release version
echo -n >prerelease.txt

# Disable warnings for unqualified `move()` calls, introduced and enabled by
# default in clang-16 which is what the emscripten docker image uses.
# Additionally, disable the warning for unknown warnings here, as this script is
# also used with earlier clang versions.
# TODO: This can be removed if and when all usages of `move()` in our codebase use the `std::` qualifier.
CMAKE_CXX_FLAGS="-Wno-unqualified-std-cast-call"

mkdir -p build
cd build
emcmake cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBoost_USE_STATIC_LIBS=1 \
    -DBoost_USE_STATIC_RUNTIME=1 \
    -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}" \
    -DTESTS=0 \
..
make soljson

cd ..
mkdir -p upload
scripts/ci/pack_soljson.sh "build/libsolc/soljson.js" "build/libsolc/soljson.wasm" upload/soljson.js
cp upload/soljson.js ./

OUTPUT_SIZE=$(ls -la soljson.js)

echo "Emscripten output size: $OUTPUT_SIZE"
