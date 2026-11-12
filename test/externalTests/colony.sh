#!/usr/bin/env bash

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
# (c) 2019 solidity contributors.
#------------------------------------------------------------------------------

set -e

export NODE_OPTIONS="--max-old-space-size=4096"

source scripts/common.sh
source scripts/externalTests/common.sh

REPO_ROOT=$(realpath "$(dirname "$0")/../..")

verify_input "$@"
BINARY_TYPE="$1"
BINARY_PATH="$(realpath "$2")"
SELECTED_PRESETS="$3"

function compile_fn { npx hardhat compile; }
function test_fn { pnpm run test:contracts; }

function colony_test
{
    local repo="https://github.com/JoinColony/colonyNetwork.git"
    local ref="08bca31eeb5c695aa0c5868cc905e7f238163c84" # develop as of 2026-11-04
    local config_file="hardhat.config.js"

    local compile_only_presets=()
    local settings_presets=(
        "${compile_only_presets[@]}"
        legacy-no-optimize
        legacy-optimize-evm-only
        legacy-optimize-evm+yul
        #ir-no-optimize          # Compilation fails with "YulException: Variable var_dominantSigSeen is 3 too deep in the stack". No memoryguard was present.
        #ir-optimize-evm-only    # Compilation fails with "YulException: Variable var_dominantSigSeen is 3 too deep in the stack". No memoryguard was present.
        ir-optimize-evm+yul
    )

    [[ $SELECTED_PRESETS != "" ]] || SELECTED_PRESETS=$(circleci_select_steps_multiarg "${settings_presets[@]}")
    print_presets_or_exit "$SELECTED_PRESETS"

    setup_solc "$DIR" "$BINARY_TYPE" "$BINARY_PATH"
    download_project "$repo" "$ref" "$DIR"

    neutralize_package_json_hooks
    force_hardhat_compiler_binary "$config_file" "$BINARY_TYPE" "$BINARY_PATH"
    force_hardhat_compiler_settings "$config_file" "$(first_word "$SELECTED_PRESETS")"
    sudo npm install -g pnpm@8.14.1
    pnpm add -w hardhat@2.27.1 hardhat-gas-reporter
    git submodule update --init

    # lib/createx ships a committed Hardhat build-info (solc 0.8.23), which trips the compiler version check.
    rm -r lib/createx/artifacts/

    replace_version_pragmas
    remove_experimental_abi_encoder_v2_pragmas
    # Replace the single usage of virtual modifiers in this project.
    sed -i '
        # Delete the placeholder of the virtual modifier.
        /modifier auth virtual {/,/_;/ { /_;/ d }
        # Add a non-virtual modifier calling a new virtual function that takes over the original body.
        s|modifier auth virtual {|modifier auth { _checkAuth(); _; }\n    function _checkAuth() internal view virtual {|
    ' lib/dappsys/auth.sol
    sed -i '
        # Delete the placeholder of the overriding modifier.
        /modifier auth() override {/,/_;/ { /_;/ d }
        # Turn the overriding modifier into an override of the new function.
        s|modifier auth() override {|function _checkAuth() internal view override {|
    ' contracts/colony/ColonyStorage.sol

    for preset in $SELECTED_PRESETS; do
        hardhat_run_test "$config_file" "$preset" "${compile_only_presets[*]}" compile_fn test_fn
        store_benchmark_report hardhat colony "$repo" "$preset"
    done
}

external_test ColonyNetworks colony_test
