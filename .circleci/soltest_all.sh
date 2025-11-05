#! /bin/bash
#------------------------------------------------------------------------------
# Bash script to execute the Solidity tests by CircleCI.
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
set -e

REPODIR="$(realpath "$(dirname "$0")"/..)"

# shellcheck source=scripts/common.sh
source "${REPODIR}/scripts/common.sh"

DEFAULT_EVM_VALUES=(constantinople petersburg istanbul berlin london paris shanghai cancun prague osaka)
EVMS_WITH_EOF=(osaka)

# Deserialize the EVM_VALUES array if it was provided as argument or
# set EVM_VALUES to the default values.
IFS=" " read -ra EVM_VALUES <<< "${1:-${DEFAULT_EVM_VALUES[@]}}"

DEFAULT_EVM=prague
OPTIMIZE_VALUES=(0 1)
# TODO: EOF is marked as experimental in evmone. Reenable when proper handling for that is added here.
EOF_VERSIONS=(0)

# Run for ABI encoder v1, without SMTChecker tests.
EVM="${DEFAULT_EVM}" \
OPTIMIZE=1 \
ABI_ENCODER_V1=1 \
BOOST_TEST_ARGS="-t !smtCheckerTests" \
"${REPODIR}/.circleci/soltest.sh"

# We shift the batch index so that long-running tests
# do not always run in the same executor for all EVM versions
INDEX_SHIFT=0
for OPTIMIZE in "${OPTIMIZE_VALUES[@]}"
do
    for EVM in "${EVM_VALUES[@]}"
    do
        for EOF_VERSION in "${EOF_VERSIONS[@]}"
        do
            if (( EOF_VERSION > 0 )) && [[ ! " ${EVMS_WITH_EOF[*]} " == *" $EVM "* ]]; then
                continue
            fi

            ENFORCE_GAS_ARGS=""
            [ "${EVM}" = "${DEFAULT_EVM}" ] && ENFORCE_GAS_ARGS="--enforce-gas-cost"
            # Run SMTChecker tests only when OPTIMIZE == 0
            DISABLE_SMTCHECKER=""
            [ "${OPTIMIZE}" != "0" ] && DISABLE_SMTCHECKER="-t !smtCheckerTests"

            EVM="$EVM" \
            EOF_VERSION="$EOF_VERSION" \
            OPTIMIZE="$OPTIMIZE" \
            SOLTEST_FLAGS="$SOLTEST_FLAGS $ENFORCE_GAS_ARGS" \
            BOOST_TEST_ARGS="-t !@nooptions $DISABLE_SMTCHECKER" \
            INDEX_SHIFT="$INDEX_SHIFT" \
            "${REPODIR}/.circleci/soltest.sh"

            INDEX_SHIFT=$((INDEX_SHIFT + 1))
        done
    done
done
