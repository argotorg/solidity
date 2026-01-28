#! /bin/bash
#------------------------------------------------------------------------------
# Bash script to install osx dependencies
#
# The documentation for solidity is hosted at:
#
#     https://docs.soliditylang.org
#
# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2016-2019 solidity contributors.
# ------------------------------------------------------------------------------

# note that the following directories may be cached by circleci:
# - /usr/local
# - /opt/homebrew

set -eu

function validate_checksum {
  local package="$1"
  local expected_checksum="$2"

  local actual_checksum
  actual_checksum=$(sha256sum "$package")
  if [[ $actual_checksum != "${expected_checksum}  ${package}" ]]
  then
    >&2 echo "ERROR: Wrong checksum for package $package."
    >&2 echo "Actual:   $actual_checksum"
    >&2 echo "Expected: $expected_checksum"
    exit 1
  fi
}

if [ ! -f /usr/local/lib/libz3.a ] # if this file does not exists (cache was not restored), rebuild dependencies
then
  brew update
  brew upgrade
  brew install cmake
  brew install wget
  brew install coreutils
  brew install diffutils
  brew install grep
  # JRE is required to run eldarica solver
  brew install openjdk@11
  brew install unzip

  # boost
  boost_version="1.84.0"
  boost_package="boost_${boost_version//./_}.tar.bz2"
  boost_dir="boost_${boost_version//./_}"
  wget "https://archives.boost.io/release/$boost_version/source/$boost_package"
  tar xf "$boost_package"
  rm "$boost_package"
  cd "$boost_dir"
  ./bootstrap.sh --with-toolset=clang --with-libraries=thread,system,filesystem,program_options,serialization,test
  # the default number of jobs that b2 is taking, is the number of detected available CPU threads.
  # install boost to /opt/boost, to use it in CMake, specify Boost_ROOT
  sudo ./b2 -a address-model=64 architecture=arm+x86 --prefix=/opt/boost install
  cd ..
  sudo rm -rf "$boost_dir"

  # eldarica
  eldarica_version="2.1"
  wget "https://github.com/uuverifiers/eldarica/releases/download/v${eldarica_version}/eldarica-bin-${eldarica_version}.zip" -O /tmp/eld_binaries.zip
  validate_checksum /tmp/eld_binaries.zip 0ac43f45c0925383c9d2077f62bbb515fd792375f3b2b101b30c9e81dcd7785c
  unzip /tmp/eld_binaries.zip -d /tmp
  sudo mv /tmp/eldarica/{eld,eld-client,target,eldEnv} /usr/local/bin
  rm -rf /tmp/{eldarica,eld_binaries.zip}

  #cvc5
  cvc5_version="1.2.0"
  cvc5_archive_name="cvc5-macOS-arm64-static"
  wget "https://github.com/cvc5/cvc5/releases/download/cvc5-${cvc5_version}/${cvc5_archive_name}.zip" -O /tmp/cvc5.zip
  validate_checksum /tmp/cvc5.zip 57d2d4855af3f3865110a254e415098b4e150a655f297010e27eb292f48f7da7
  sudo unzip -j /tmp/cvc5.zip "${cvc5_archive_name}/bin/cvc5" -d /usr/local/bin
  rm -f /tmp/cvc5.zip

  # z3
  z3_version="4.13.3"
  z3_dir="z3-z3-$z3_version"
  z3_package="z3-$z3_version.tar.gz"
  wget "https://github.com/Z3Prover/z3/archive/refs/tags/$z3_package"
  validate_checksum "$z3_package" f59c9cf600ea57fb64ffeffbffd0f2d2b896854f339e846f48f069d23bc14ba0
  tar xf "$z3_package"
  rm "$z3_package"
  cd "$z3_dir"
  mkdir build
  cd build
  cmake -DCMAKE_OSX_ARCHITECTURES:STRING="x86_64;arm64" -DZ3_BUILD_LIBZ3_SHARED=false ..
  make -j "$(nproc)"
  sudo make install
  cd ../..
  rm -rf "$z3_dir"

  # evmone
  evmone_version="0.16.0"
  evmone_package="evmone-${evmone_version}-darwin-arm64.tar.gz"
  wget "https://github.com/ipsilon/evmone/releases/download/v${evmone_version}/${evmone_package}"
  validate_checksum "$evmone_package" d26bcf7ada6c712b669ee70cbd8b534f80dadb6207fa15e15d1517d2b6823aa8
  sudo tar xzpf "$evmone_package" -C /usr/local
  rm "$evmone_package"
fi
