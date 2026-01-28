#!/usr/bin/env bash
set -e

ROOTDIR=$(dirname "$0")/..
BUILDDIR="${ROOTDIR}/build"

if (( $# == 0 )); then
    BUILD_TYPE=Release
else
    BUILD_TYPE="$1"
fi

# Intentionally not using prerelease_suffix.sh here. We do not want lingering prerelease.txt in
# dev builds, accidentally overriding version when someone runs the build manually.
if [[ $(git tag --points-at HEAD 2> /dev/null) =~ ^v[0-9.]+$ ]]; then
    echo -n > prerelease.txt
fi

mkdir -p "$BUILDDIR"
cd "$BUILDDIR"

cmake .. -DCMAKE_BUILD_TYPE="$BUILD_TYPE" "${@:2}"
make -j2

if [[ $CI == "" ]]; then
    echo "Installing ..."
    sudo make install
fi
