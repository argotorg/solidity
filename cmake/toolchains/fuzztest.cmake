# Toolchain for building the FuzzTest property-based tests in coverage-guided fuzzing
# mode (PROPERTY_BASED_TESTS_MODE=fuzzing). Fuzzing mode requires Clang.
#
#   CC=clang CXX=clang++ cmake -S . -B build-fuzz -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/fuzztest.cmake
#
# The instrumentation flags are applied globally (a toolchain file is processed before
# project()), so every solidity library under test is built with ASan + coverage, not just
# the translation units in test/fuzztest.

# Inherit default options
include("${CMAKE_CURRENT_LIST_DIR}/default.cmake")

# Turn on the property tests in fuzzing mode.
set(PROPERTY_BASED_TESTS ON CACHE BOOL "Enable FuzzTest property-based tests" FORCE)
set(PROPERTY_BASED_TESTS_MODE "fuzzing" CACHE STRING "Property-based test mode" FORCE)

# Pull the instrumentation flags straight from FuzzTest's own helper. For this we require the submodule to be initialized.
set(FUZZTEST_PATH_TO_FLAG_SETUP "${CMAKE_CURRENT_LIST_DIR}/../../deps/fuzztest/cmake/FuzzTestFlagSetup.cmake")
if (NOT EXISTS "${FUZZTEST_PATH_TO_FLAG_SETUP}")
	message(FATAL_ERROR
		"deps/fuzztest submodule is not initialized; the fuzztest toolchain needs it at configure time.\n"
		"Run: git submodule update --init deps/fuzztest")
endif()

set(FUZZTEST_FUZZING_MODE ON)
# Reset the base before invoking the (appending) helper. A toolchain file is re-read on every CMake pass.
# Resetting first makes the resulting flags identical no matter how many times this runs.
set(CMAKE_CXX_FLAGS "")
set(CMAKE_EXE_LINKER_FLAGS "")
include("${FUZZTEST_PATH_TO_FLAG_SETUP}")
fuzztest_setup_fuzzing_flags()
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" CACHE STRING "Custom compilation flags" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" CACHE STRING "Custom linker flags" FORCE)
