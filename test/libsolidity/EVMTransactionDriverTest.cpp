/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
// SPDX-License-Identifier: GPL-3.0
/**
 * Smallest possible round trip through EVMTransactionDriver: deploy a contract via a CREATE
 * transaction, then read a value back via a CALL transaction, entirely through
 * evmone::state::transition() -- without going through ExecutionFramework's --use-evmone-state
 * switch (test/CommonOptions is left completely alone here; this suite drives EVMTransactionDriver
 * directly, deliberately kept separate from the --use-evmone-state integration path below).
 *
 * This is intentionally lower-level than a semantic test: it drives EVMTransactionDriver directly,
 * the same way EVMStateSmokeTest.cpp (removed by this same change) proved evmone::state was linked
 * in at all. test/libsolidity/semanticTests/storage/state_smoke_test.sol run with
 * --use-evmone-state is the corresponding end-to-end proof through the full ExecutionFramework
 * integration; see CommonOptions::useEvmoneState's doc comment (test/Common.h) for what that
 * integration does and does not cover.
 */

#include <test/libsolidity/SolidityExecutionFramework.h>

#include <test/EVMHost.h>
#include <test/EVMTransactionDriver.h>

#include <libsolutil/FunctionSelector.h>
#include <libsolutil/Numeric.h>

#include <boost/test/unit_test.hpp>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::test;

namespace solidity::frontend::test
{

BOOST_FIXTURE_TEST_SUITE(EVMTransactionDriverTest, SolidityExecutionFramework)

BOOST_AUTO_TEST_CASE(deploy_and_call_a_getter)
{
	// The shape mirrors test/libsolidity/semanticTests/various/erc20.sol's "constructor(), then a
	// call" structure and test/libsolidity/semanticTests/storage/simple_accessor.sol's single
	// getter, simplified to the smallest contract that still exercises a constructor storing a
	// value and a function reading it back through the ABI.
	bytes const bytecode = compileContract(R"(
		contract Getter {
			uint256 private storedValue;
			constructor() {
				storedValue = 42;
			}
			function get() public view returns (uint256) {
				return storedValue;
			}
		}
	)");
	BOOST_REQUIRE(!bytecode.empty());

	// Deliberately not going through ExecutionFramework::selectVM()/CommonOptions::useEvmoneState:
	// this test only needs a driver, not the whole switch that lets SemanticTest pick one.
	EVMTransactionDriver driver(m_evmVersion, EVMHost::getVM());
	BOOST_REQUIRE(driver.stateView().accounts.empty());

	evmc::address const sender = EVMHost::convertToEVMC(account(0));
	// Mirrors ExecutionFramework::reset(): a funded account whose nonce already reads 1, so the
	// first CREATE derives its address from nonce 1 rather than 0.
	driver.stateView().accounts[sender].balance = toEvmoneUint256(u256(1) << 100);
	driver.stateView().accounts[sender].nonce = 1;

	evmone::state::Transaction creation;
	creation.sender = sender;
	creation.data = evmc::bytes(bytecode.begin(), bytecode.end());
	creation.gas_limit = static_cast<int64_t>(evmone::state::MAX_TX_GAS_LIMIT);
	creation.max_gas_price = driver.gasPrice();
	creation.max_priority_gas_price = driver.gasPrice();
	creation.nonce = driver.stateView().accounts.at(sender).nonce;

	driver.newBlock();
	evmone::state::TransactionReceipt const creationReceipt = driver.run(creation);
	BOOST_REQUIRE(creationReceipt.status == EVMC_SUCCESS);

	evmc::address const contractAddress = driver.lastRecipient();
	BOOST_REQUIRE(!driver.stateView().get_account_code(contractAddress).empty());

	bytes const selector = selectorFromSignatureH32("get()").asBytes();

	evmone::state::Transaction call;
	call.sender = sender;
	call.to = contractAddress;
	call.data = evmc::bytes(selector.begin(), selector.end());
	call.gas_limit = static_cast<int64_t>(evmone::state::MAX_TX_GAS_LIMIT);
	call.max_gas_price = driver.gasPrice();
	call.max_priority_gas_price = driver.gasPrice();
	call.nonce = driver.stateView().accounts.at(sender).nonce;

	driver.newBlock();
	evmone::state::TransactionReceipt const callReceipt = driver.run(call);
	BOOST_REQUIRE(callReceipt.status == EVMC_SUCCESS);
	BOOST_CHECK_EQUAL(util::toHex(driver.lastOutput()), util::toHex(toBigEndian(u256(42))));
}

// A failed creation (REVERT, not a thrown-C++ validation error) exercises EVMTransactionDriver::
// run()'s probe/official cross-check on a very different gas profile than a successful call: a
// REVERT typically leaves execution gas unspent but grants no refund, and (unlike a successful
// CREATE) deposits no code at all. This is exactly the shape the strengthened cross-check in
// run() (comparing gas_used/gas_refund, not just status) needs to agree on for both the probe and
// the official transition() run, and also the shape ExecutionFramework.cpp's code-deposit-gas
// reconstruction comment (near StateDiff-driven gas accounting) discusses: a failed creation must
// not leave code or storage behind.
BOOST_AUTO_TEST_CASE(create_that_reverts)
{
	// REVERT arrived with Byzantium (EIP-140). Before that a failing constructor consumes all
	// gas instead of reverting with data, so neither the EVMC_REVERT status nor the returned
	// revert reason this case is about exist. soltest_all sweeps every EVM version, so the
	// guard is required rather than merely tidy.
	if (!m_evmVersion.supportsReturndata())
		return;

	bytes const bytecode = compileContract(R"(
		contract Reverter {
			constructor() {
				revert("nope");
			}
		}
	)");
	BOOST_REQUIRE(!bytecode.empty());

	EVMTransactionDriver driver(m_evmVersion, EVMHost::getVM());

	evmc::address const sender = EVMHost::convertToEVMC(account(0));
	driver.stateView().accounts[sender].balance = toEvmoneUint256(u256(1) << 100);
	driver.stateView().accounts[sender].nonce = 1;

	evmone::state::Transaction creation;
	creation.sender = sender;
	creation.data = evmc::bytes(bytecode.begin(), bytecode.end());
	creation.gas_limit = static_cast<int64_t>(evmone::state::MAX_TX_GAS_LIMIT);
	creation.max_gas_price = driver.gasPrice();
	creation.max_priority_gas_price = driver.gasPrice();
	creation.nonce = driver.stateView().accounts.at(sender).nonce;

	driver.newBlock();
	// run() itself asserts (via soltestAssert) that the probe and the official transition() agree
	// on status and on gas_used/gas_refund; simply not throwing here is already most of the point
	// of this test.
	evmone::state::TransactionReceipt const receipt = driver.run(creation);
	BOOST_CHECK(receipt.status == EVMC_REVERT);

	evmc::address const contractAddress = driver.lastRecipient();
	BOOST_CHECK(driver.stateView().get_account_code(contractAddress).empty());
	BOOST_CHECK(!driver.lastOutput().empty()); // The ABI-encoded Error(string) revert reason.
}

BOOST_AUTO_TEST_SUITE_END()

}
