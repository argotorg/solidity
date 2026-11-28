#!/usr/bin/env python3

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
# (c) 2026 solidity contributors.
# ------------------------------------------------------------------------------

import sys
from pathlib import Path

# Our scripts/ is not a proper Python package so we need to modify PYTHONPATH to import from it
# pragma pylint: disable=import-error,wrong-import-position
PROJECT_ROOT = Path(__file__).parents[2]
sys.path.insert(0, f"{PROJECT_ROOT}/scripts/externalTests")

from runners.base import run_test
from runners.base import TestConfig
from runners.base import BaseRunner
from runners.foundry import FoundryRunner
from runners.foundry import run_forge_command
from test_helpers import replace_in_solidity_sources
from test_helpers import SettingsPreset

class UniswapRunner(FoundryRunner):
    def setup_environment(self):
        super().setup_environment()
        # Virtual modifiers are disallowed. Nothing overrides this one.
        replace_in_solidity_sources(
            self.test_dir,
            r"modifier onlyOwner\(\) virtual",
            "modifier onlyOwner()",
            "lib/solmate/src/auth/Owned.sol",
        )
        # Uncomment if https://github.com/argotorg/solidity/issues/6337 gets resolved and this test breaks
        #replace_in_solidity_sources(self.test_dir, r"Pool\.State public pool;", "Pool.State pool;", "test/Tick.t.sol")

    @BaseRunner.enter_test_dir
    def run_test(self):
        # The test suite expects each top-level call to be executed as a separate transaction,
        # which is achieved with the --isolate flag.
        run_forge_command("forge test --isolate --gas-report", self.env)

test_config = TestConfig(
    name="Uniswap-V4",
    repo_url="https://github.com/Uniswap/v4-core.git",
    ref="bea7f6d1c11cd5dc4f0d5151ffa37a1c239feee6", # main as of 2026-10-23
    settings_presets=[
        SettingsPreset.LEGACY_NO_OPTIMIZE,
        SettingsPreset.LEGACY_OPTIMIZE_EVM_ONLY,
        SettingsPreset.LEGACY_OPTIMIZE_EVM_YUL,
        SettingsPreset.IR_NO_OPTIMIZE,
        SettingsPreset.IR_OPTIMIZE_EVM_ONLY,
        # SettingsPreset.IR_OPTIMIZE_EVM_YUL, # Compilation fails with "Variable memPtr_1 is 1 too deep in the stack".
    ],
)

sys.exit(run_test(UniswapRunner(argv=sys.argv[1:], config=test_config)))
