#!/usr/bin/env bash
set -ex

ROOTDIR="$(realpath "$(dirname "$0")/../..")"
BUILDDIR="${ROOTDIR}/build_ossfuzz"
mkdir -p "${BUILDDIR}" && mkdir -p "$BUILDDIR/deps"

function generate_protobuf_bindings
{
  cd "${ROOTDIR}"/test/tools/ossfuzz
  # Generate protobuf C++ bindings
  for protoName in yul abiV2 sol;
  do
    protoc "${protoName}"Proto.proto --cpp_out .
  done
}

function build_fuzzers
{
  cd "${BUILDDIR}"
  cmake .. -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}" -DCCACHE=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_TOOLCHAIN_FILE="${ROOTDIR}"/cmake/toolchains/libfuzzer.cmake
  make ossfuzz ossfuzz_proto ossfuzz_abiv2 -j 8
}

generate_protobuf_bindings
build_fuzzers
