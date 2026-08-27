# Fetches evmone (and its intx dependency) from pinned release archives, and builds evmone's own
# EVMC (evmc, evmc_cpp, mocked_host) and evmone targets as part of Solidity's build tree.
#
# Versions and hashes are copied from evmone's own cmake/Hunter/config.cmake.
include(FetchContent)

# Recursively strips every compile warning flag from every "real" (i.e. actually compiled) target
# CMake has defined at and below a given source directory, by appending -w ("inhibit all warning
# messages") to each. Used below, once evmone's own tree has been add_subdirectory()'d, to insulate
# it from Solidity's PEDANTIC=ON warnings-as-errors policy.
#
# Why evmone needs this at all, not just "why does its build fail": evmone's own top-level
# CMakeLists.txt neutralises exactly the warnings its own code deliberately triggers --
# [[clang::no_sanitize(...)]]/[[msvc::forceinline]] scoped attributes (unrecognised-attribute
# warnings under -pedantic on a GCC that does not implement them), and partial designated
# initializers of evmc_message literals (-Wmissing-field-initializers) -- with its own
# `-Wno-attributes=clang::`/`-Wno-attributes=msvc::`/`-Wno-missing-field-initializers` flags. But
# it only adds those flags inside `if(CABLE_COMPILER_GNULIKE)` (evmone's CMakeLists.txt), and
# CABLE_COMPILER_GNULIKE is a variable that only `cable_configure_compiler()` sets (Cable's own
# CableCompilerSettings.cmake), and only `if(PROJECT_IS_TOP_LEVEL)` -- a CMake builtin variable
# that is true only for the very first project() call of the whole configure run. Solidity's own
# project(solidity ...) is that first call; evmone's project(evmone ...), reached via
# add_subdirectory() below, is not, so PROJECT_IS_TOP_LEVEL is false for it, CABLE_COMPILER_GNULIKE
# is never set, and evmone's own suppressions above never run -- verified directly by configuring a
# from-scratch build with no -DPEDANTIC argument at all (i.e. PEDANTIC's real default, ON) and
# watching lib/evmone_precompiles/blake2b.cpp and sha256.cpp fail with
# "'clang::no_sanitize' scoped attribute directive ignored [-Werror=attributes]", which stops
# reproducing once this function is applied to evmone's targets.
#
# Solidity's own PEDANTIC=ON block (EthCompilerSettings.cmake) calls plain add_compile_options(-Wall
# -Wextra -Werror -pedantic ...) at its own top-level directory scope, long before add_subdirectory()
# ever reaches this file (CMakeLists.txt: EthCompilerSettings is include()d, then add_subdirectory
# (test) eventually reaches include(EvmoneDependency)) -- and CMake directory-scope COMPILE_OPTIONS
# are inherited by every add_subdirectory() added afterwards, with no opt-out short of this. So the
# fix belongs here, in the file that pulls evmone in, not in evmone's own sources (not this project's
# to maintain -- upstream already made its own, reasonable, choice for when it is the top-level
# project) and not by weakening Solidity's own PEDANTIC settings (which exist to hold Solidity's own
# code, not third-party code, to -Werror).
#
# -w, appended via target_compile_options() after the target already carries Solidity's inherited
# -Wall/-Werror/-pedantic/etc., is what actually neutralises them regardless of where it lands on
# the final command line relative to those inherited flags: "-w" means "inhibit all warning
# messages" outright, so -Werror has no warning left to promote to an error, whichever flag appears
# first. This was verified, not just assumed, against a real build: temporarily removing this
# function's call reproduces the exact "'clang::no_sanitize' scoped attribute directive ignored
# [-Werror=attributes]" failures in lib/evmone_precompiles/blake2b.cpp and sha256.cpp described
# above, unchanged from the from-scratch, no-DPEDANTIC-argument run that first surfaced them.
#
# Targets, not a directory-property reset, because CMake has no supported way to remove entries an
# ancestor directory already added to the COMPILE_OPTIONS a child directory inherited -- only to add
# more on top -- and BUILDSYSTEM_TARGETS/SUBDIRECTORIES are walked recursively, rather than naming
# each target once by hand, so that nothing pulled in by a future evmone version bump (a new source
# file, a new sub-library) is silently missed and left to break the default build again. Only
# STATIC_LIBRARY/SHARED_LIBRARY/MODULE_LIBRARY/OBJECT_LIBRARY/EXECUTABLE targets are touched:
# INTERFACE_LIBRARY targets (evmc, evmc_cpp, mocked_host, intx, evmone's own header-only evmmax) have
# no compiled sources of their own for a warning flag to apply to, and target_compile_options(...
# PRIVATE ...) on one is a hard configure error, not a no-op; UTILITY targets (custom targets/
# commands) do not compile anything either. blst -- built by evmone's cmake/blst.cmake via
# ExternalProject_Add() as a wholly separate build.sh invocation with its own hand-assembled CC/
# CFLAGS, then wired in as an IMPORTED STATIC library -- is untouched by any of this: it was never
# subject to Solidity's inherited COMPILE_OPTIONS in the first place (ExternalProject_Add() does not
# read that property; IMPORTED targets are excluded from BUILDSYSTEM_TARGETS and never even matched
# by this walk), which is also why its own build never appeared in the -Werror failures this
# function fixes.
function(eth_disable_warnings_recursively source_dir)
    get_property(targets DIRECTORY "${source_dir}" PROPERTY BUILDSYSTEM_TARGETS)
    foreach(target IN LISTS targets)
        get_target_property(target_type ${target} TYPE)
        if(NOT target_type STREQUAL "INTERFACE_LIBRARY" AND NOT target_type STREQUAL "UTILITY")
            target_compile_options(${target} PRIVATE -w)
        endif()

        # Suppressing warnings on evmone's own targets is not enough: Solidity compiles
        # test/evmc/loader.c itself, and that translation unit includes evmone's
        # <evmc/evmc.h>, so Solidity's own -Werror -pedantic applies to *their* header.
        # EVMC 18 declares `enum evmc_access_status : bool`, which is C23; under the C17
        # default that most compilers still use, that is
        #   error: ISO C does not support specifying 'enum' underlying types before C23
        # and the build fails. This is invisible on a toolchain whose default C dialect is
        # already C23 (gcc 15+), which is exactly why it reached CI unnoticed.
        #
        # Marking the interface include directories as SYSTEM makes consumers use -isystem
        # for them, which is the documented way to say "not our code, do not lint it". It
        # fixes every consuming translation unit, not just the loader, and does not change
        # include resolution order for Solidity's own headers, which are still passed with
        # plain -I and therefore searched first.
        get_target_property(interface_includes ${target} INTERFACE_INCLUDE_DIRECTORIES)
        if(interface_includes)
            set_target_properties(
                ${target} PROPERTIES
                INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${interface_includes}"
            )
        endif()
    endforeach()

    get_property(subdirectories DIRECTORY "${source_dir}" PROPERTY SUBDIRECTORIES)
    foreach(subdirectory IN LISTS subdirectories)
        eth_disable_warnings_recursively(${subdirectory})
    endforeach()
endfunction()

FetchContent_Declare(
    intx
    URL https://github.com/chfast/intx/archive/v0.15.0.tar.gz
    URL_HASH SHA1=571b3f4c5a7b09135755720b478bc03f9d7ba7bb
)
# Single-argument form, deliberately, not merely because it is what an older CMake still allows:
# it downloads intx without configuring or building it, which is what EVMONE_INTX_DIR below
# needs -- evmone add_subdirectory()s that source tree itself. FetchContent_MakeAvailable(intx)
# would additionally add_subdirectory() it right here, i.e. twice for the same source directory,
# which is a duplicate-target configure error, not just a redundant no-op. CMake 4 deprecates
# this single-argument form and warns that the ability to call it with declared details will be
# removed in a future version (policy CMP0169); pin OLD explicitly for this one call so the
# warning is silenced because the deprecated behavior is exactly what is wanted here, not because
# the warning was papered over. CMP0169 itself is a CMake 3.30 addition, newer than the 3.25 this
# project actually requires, so guard the SET with if(POLICY ...): on a real 3.25..3.29 CMake, the
# policy ID does not exist yet and cmake_policy(SET CMP0169 ...) is not a no-op but a hard
# "Policy \"CMP0169\" is not known to this version of CMake" configure error (verified against a
# real 3.25.0 binary) -- and on those versions there is no warning to silence in the first place,
# since the policy that would produce it does not exist yet either.
if(POLICY CMP0169)
    cmake_policy(SET CMP0169 OLD)
endif()
FetchContent_Populate(intx)

# No EXCLUDE_FROM_ALL keyword here: that keyword on FetchContent_Declare() is itself a CMake 3.28
# addition (it is threaded through to the add_subdirectory() call inside
# FetchContent_MakeAvailable()), newer than the 3.25 minimum this project targets. The exclusion
# this project actually wants -- nothing evmone defines should join the default `ninja all`/
# `make all` target merely because Solidity links its evmc/evmone/evmone::state libraries, in
# particular not the tools/evmone CLI binary or the test/utils testutils library that EVMONE_TOOLS
# below additionally switches on -- is achieved manually below, with the FetchContent_Populate() +
# add_subdirectory(... EXCLUDE_FROM_ALL) pattern that CMake's own FetchContent documentation gives
# as the pre-3.28, pre-FetchContent_MakeAvailable() way to do this (see the
# FetchContent_GetProperties() docs). Unlike intx above, evmone does need to be add_subdirectory()'d
# here -- this project links its evmone and evmc targets directly -- so the single-argument
# Populate-only call that intx uses is not enough on its own; the difference from intx is which
# step (populate vs. configure) each dependency actually needs skipped or kept. Verified directly
# with `ninja -t inputs all`: it lists evmone::state's own inputs but neither evmone-cli's nor
# evmone.testutils's -- dry-run `ninja -n all` cannot be used for this check, since it can never see
# past this project's own CONFIGURE_DEPENDS glob-recheck gate (cmake/EthUtils.cmake), which always
# reports needing to re-run CMake first, regardless of actual staleness.
FetchContent_Declare(
    evmone
    URL https://github.com/ipsilon/evmone/archive/refs/tags/v0.23.0.tar.gz
    URL_HASH SHA256=7acb0c25fee04797aa89d8631673449138af3c360dc0ec3ea41b4f3c56dd3564
)

# EVMONE_TOOLS=ON (below) makes tools/evmone/CMakeLists.txt do hunter_add_package(CLI11) --
# a no-op, see the Hunter comment below -- followed by find_package(CLI11 CONFIG REQUIRED), which
# needs satisfying some other way. Unlike nlohmann_json, Solidity has no CLI11 of its own to point
# that at, so it is fetched here, pinned to the same version and hash evmone's own
# cmake/Hunter/config.cmake records. OVERRIDE_FIND_PACKAGE is the documented FetchContent mechanism
# for exactly this case (CMake's FetchContent docs, "OVERRIDE_FIND_PACKAGE"): it makes every
# find_package(CLI11 ...) call anywhere in the build -- including the one inside evmone's own
# CMakeLists.txt, which this file never touches -- first ensure FetchContent_MakeAvailable(CLI11)
# has run, then resolve against the CLI11::CLI11 target that call defines, via an
# ${CMAKE_FIND_PACKAGE_REDIRECTS_DIR} config file that FetchContent itself generates. No manual
# redirect file is needed here, unlike the nlohmann_json case below, because CLI11 does not already
# have a target defined elsewhere in this build for such a file to point at.
# No EXCLUDE_FROM_ALL keyword here, deliberately, and not merely because OVERRIDE_FIND_PACKAGE
# (a 3.24 addition, fine at this project's 3.25 floor) satisfies find_package(CLI11 ...) either
# way: EXCLUDE_FROM_ALL as a FetchContent_Declare() keyword is itself a 3.28 addition -- newer than
# the floor -- and would be redundant here even where it is recognized. CLI11 is header-only (an
# INTERFACE library with no compiled sources unless CLI11_PRECOMPILED is set, which nothing here
# sets), so exclusion is belt-and-braces regardless of the keyword's presence: CLI11's directory is
# nested inside evmone's already-EXCLUDE_FROM_ALL tree either way (it is add_subdirectory()'d from
# within tools/evmone/CMakeLists.txt's find_package() call, itself already beneath the
# add_subdirectory(... EXCLUDE_FROM_ALL) call below), and CLI11_BUILD_EXAMPLES/CLI11_BUILD_TESTS/
# CLI11_BUILD_DOCS all default OFF here anyway because CLI11's CMakeLists.txt gates them on its own
# project() being the top-level one, which it is not. Nothing under tools/ is part of `ninja all`;
# see the evmone declare's comment above for how that is verified.
FetchContent_Declare(
    CLI11
    URL https://github.com/CLIUtils/CLI11/archive/v2.5.0.tar.gz
    URL_HASH SHA1=8411927bd2fa7c8fc6dff4c53a31cde4a9017f9c
    OVERRIDE_FIND_PACKAGE
)

# evmone resolves intx via Hunter, which cannot run from a subproject: HunterGate() injects
# CMAKE_TOOLCHAIN_FILE, which CMake only reads once, at the very first top-level project() call in
# the whole build -- by the time evmone's own project(evmone ...) runs here, Solidity's
# project(solidity ...) has long since happened, so the injection has no effect. Worse,
# HunterGate() actively refuses to run a second time from within an already-named project: it
# errors with "Please set HunterGate *before* 'project' command. Detected project: solidity".
# EVMONE_INTX_DIR (evmone's own escape hatch) supplies intx directly via add_subdirectory()
# instead, and disabling Hunter (below) means the erroring path is never even reached.
#
# EVMONE_INTX_DIR, EVMONE_TOOLS and EVMONE_TESTING are evmone-specific cache variable names with
# no other consumer anywhere in Solidity's own build, so forcing them into the project-wide cache
# is safe -- nothing else reads or sets them, so there is nothing to collide with.
set(EVMONE_INTX_DIR ${intx_SOURCE_DIR} CACHE PATH "" FORCE)
# ON: evmone's CMakeLists.txt (157-162) adds test/state, test/utils and tools/ under this flag.
# evmone::state (test/state) is what this project actually wants; test/utils and tools/evmone
# (an "evmone" CLI binary) come along for free because evmone does not offer a finer-grained knob,
# but neither is built by default -- see the EXCLUDE_FROM_ALL comment above the evmone declare,
# which this inherits recursively. EVMONE_TOOLS=ON also means evmone's CMakeLists.txt now calls
# find_package(nlohmann_json CONFIG REQUIRED) and, via tools/evmone/CMakeLists.txt,
# find_package(CLI11 CONFIG REQUIRED); both are satisfied below and above respectively, since
# hunter_add_package() immediately preceding each is a no-op here (see the Hunter comment below).
set(EVMONE_TOOLS ON CACHE BOOL "" FORCE)
# EVMONE_TESTING would additionally require EVMONE_TOOLS (already ON) and pull in GTest plus the
# test/evm-benchmarks git submodule, which a release archive such as this one does not contain --
# deliberately left OFF.
set(EVMONE_TESTING OFF CACHE BOOL "" FORCE)

# evmone's EVMONE_TOOLS path (CMakeLists.txt:157-159) calls
# find_package(nlohmann_json CONFIG REQUIRED), but hunter_add_package() immediately before it is a
# no-op here. Solidity has already defined nlohmann_json::nlohmann_json itself, at the top-level
# CMakeLists.txt:64 (include(nlohmann-json) -> add_subdirectory(deps/nlohmann-json)), long before
# add_subdirectory(test) reaches this file -- so satisfying find_package() needs no new target,
# only something for it to find. ${CMAKE_FIND_PACKAGE_REDIRECTS_DIR} is a directory find_package()
# always checks first (CMake's own CMAKE_FIND_PACKAGE_REDIRECTS_DIR docs); writing an empty config
# there, rather than FetchContent_Declare(... OVERRIDE_FIND_PACKAGE) as used for CLI11 above, is
# deliberate: that mechanism add_subdirectory()s its own copy of the named source on first use, and
# Solidity's nlohmann_json is already add_subdirectory()'d once by the include() above -- a second
# copy would be the same duplicate-target configure error documented for intx higher up this file.
# evmone's own test/state and test/utils link nlohmann_json::nlohmann_json unqualified by directory
# scope (targets, unlike variables, are visible build-wide once defined), so this resolves to that
# one existing target, not a second copy -- there is nowhere in this build a second copy could even
# come from.
file(WRITE ${CMAKE_FIND_PACKAGE_REDIRECTS_DIR}/nlohmann_json-config.cmake
    "# Intentionally empty: nlohmann_json::nlohmann_json is already defined by\n"
    "# Solidity's own add_subdirectory(deps/nlohmann-json).\n")

# BUILD_SHARED_LIBS and HUNTER_ENABLED are a different case from the three variables above: both
# are generic, third-party-owned names, not evmone-specific ones.
#   - BUILD_SHARED_LIBS controls the default for every add_library() call with no explicit
#     STATIC/SHARED anywhere in the whole build -- Solidity's own libraries, and any project that
#     embeds Solidity as a subproject (see e.g. the solidity-as-cmake-dependency branch).
#   - HUNTER_ENABLED is Hunter/HunterGate's own name (cmake/cable/HunterGate.cmake, pulled in by
#     evmone's include(Hunter/init)), not evmone's; nothing in Solidity's own build reads it
#     today, but nothing here should assume that stays true forever.
# Forcing either into CACHE, as an earlier version of this file did for BUILD_SHARED_LIBS,
# permanently overwrites the user's actual setting in CMakeCache.txt: verified as a real hazard
# by configuring a scratch build with -DBUILD_SHARED_LIBS=ON, where the cache came out
# BUILD_SHARED_LIBS:BOOL=OFF afterwards. That poisoned cache value then silently outlives this
# configure run -- a later `cmake .` or CI cache reuse that does not re-pass the flag inherits it
# with no visible cause, turning every Solidity library static with no code change behind it.
#
# A plain (non-CACHE) set() inside block(SCOPE_FOR VARIABLES) fixes this: it shadows both names,
# for callers inside the block only, without writing anything to the cache. evmone's own
# `option(BUILD_SHARED_LIBS ... ON)` and HunterGate's `option(HUNTER_ENABLED ... ON)` still run
# during add_subdirectory(evmone) below and still create their respective CACHE entries (with
# evmone's own default, if the entries don't already exist) -- but a normal variable of the same
# name always shadows a same-named CACHE entry for ${...}/if() lookups in its scope, and child
# directories (add_subdirectory(), which is what FetchContent_MakeAvailable() would also do
# internally) inherit their parent's normal variables at the point they are added. So
# add_library(evmone ...) and HunterGate()'s if(HUNTER_ENABLED) still read OFF, exactly as before,
# but that OFF is gone the moment the block ends, leaving the (undamaged) cache value visible
# again everywhere else. block(SCOPE_FOR VARIABLES) is itself a CMake 3.25 addition -- exactly the
# floor this project pins to, not merely a version that happens to satisfy it.
#
# FetchContent_GetProperties()/depname_POPULATED guards this the same way CMake's own
# FetchContent_Populate() documentation does: harmless if this file is ever processed more than
# once, and it keeps the population step (no policies or variables in play yet) separate from the
# configure step (add_subdirectory(), where the BUILD_SHARED_LIBS/HUNTER_ENABLED shadowing above
# actually needs to be active).
FetchContent_GetProperties(evmone)
if(NOT evmone_POPULATED)
    FetchContent_Populate(evmone)
    block(SCOPE_FOR VARIABLES)
        set(BUILD_SHARED_LIBS OFF)
        set(HUNTER_ENABLED OFF)
        add_subdirectory(${evmone_SOURCE_DIR} ${evmone_BINARY_DIR} EXCLUDE_FROM_ALL)
    endblock()
    # See eth_disable_warnings_recursively()'s own comment, above, for why this is needed at all
    # (evmone's own -Wno-attributes=... suppressions never run once it is a subproject) and why
    # target_compile_options(-w) is what actually neutralises Solidity's inherited -Werror rather
    # than just adding more warnings on top of it. Walking from evmone_SOURCE_DIR, not
    # evmone_BINARY_DIR, is deliberate: DIRECTORY-scoped get_property() is keyed by source directory
    # (CMake's own get_property() docs, DIRECTORY option), and this reaches every target the
    # add_subdirectory() call just above defined, transitively -- evmc/evmc_cpp/mocked_host (evmc/),
    # evmone_precompiles and evmone itself (lib/), intx (add_subdirectory()'d again from inside
    # evmone's own CMakeLists.txt via EVMONE_INTX_DIR, so nested here despite living in a separate
    # FetchContent source tree), and, whenever EVMONE_TOOLS is ON, evmone-state, evmone.testutils,
    # evmone-cli and CLI11 (test/state, test/utils, tools/) as well -- with no separate call needed
    # for any of them, and nothing to update here if evmone ever adds another.
    eth_disable_warnings_recursively(${evmone_SOURCE_DIR})
endif()
