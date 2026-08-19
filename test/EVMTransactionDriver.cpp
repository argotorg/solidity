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

#include <test/EVMTransactionDriver.h>

#include <test/libsolidity/util/SoltestErrors.h>
#include <test/state/host.hpp>

#include <evmone/create_address.hpp>

#include <libsolutil/Exceptions.h>

#include <boost/throw_exception.hpp>

#include <stdexcept>
#include <variant>

using namespace evmc::literals;
using namespace solidity;
using namespace solidity::test;
using namespace evmone::state;

namespace
{

/// Maps langutil::EVMVersion to evmc_revision. Deliberately a private copy of the mapping
/// EVMHost's constructor computes for m_evmRevision (EVMHost.cpp) rather than a shared helper:
/// EVMHost.h/.cpp are untouched by this MVP, so the EVMHost path stays exactly as it was before
/// this driver existed. Keep the two in sync by hand if EVMVersion ever grows a new revision.
evmc_revision toEvmcRevision(langutil::EVMVersion _evmVersion)
{
	using langutil::EVMVersion;
	if (_evmVersion == EVMVersion::homestead())
		return EVMC_HOMESTEAD;
	else if (_evmVersion == EVMVersion::tangerineWhistle())
		return EVMC_TANGERINE_WHISTLE;
	else if (_evmVersion == EVMVersion::spuriousDragon())
		return EVMC_SPURIOUS_DRAGON;
	else if (_evmVersion == EVMVersion::byzantium())
		return EVMC_BYZANTIUM;
	else if (_evmVersion == EVMVersion::constantinople())
		return EVMC_PETERSBURG; // See the matching comment in EVMHost.cpp.
	else if (_evmVersion == EVMVersion::petersburg())
		return EVMC_PETERSBURG;
	else if (_evmVersion == EVMVersion::istanbul())
		return EVMC_ISTANBUL;
	else if (_evmVersion == EVMVersion::berlin())
		return EVMC_BERLIN;
	else if (_evmVersion == EVMVersion::london())
		return EVMC_LONDON;
	else if (_evmVersion == EVMVersion::paris())
		return EVMC_PARIS;
	else if (_evmVersion == EVMVersion::shanghai())
		return EVMC_SHANGHAI;
	else if (_evmVersion == EVMVersion::cancun())
		return EVMC_CANCUN;
	else if (_evmVersion == EVMVersion::prague())
		return EVMC_PRAGUE;
	else if (_evmVersion == EVMVersion::osaka())
		return EVMC_OSAKA;
	else if (_evmVersion == EVMVersion::amsterdam())
		return EVMC_AMSTERDAM;
	else if (_evmVersion == EVMVersion::future())
		return EVMC_MAX_REVISION;

	solThrow(util::Exception, "Unsupported EVM version");
}

}

EVMTransactionDriver::EVMTransactionDriver(langutil::EVMVersion _evmVersion, evmc::VM& _vm):
	m_vm(_vm),
	m_revision(toEvmcRevision(_evmVersion))
{
	solRequire(!!m_vm, util::Exception, "Unable to find evmone library");

	// Mirrors the block context EVMHost's constructor sets on tx_context, so the two paths are
	// comparable (EVMHost.cpp).
	m_block.gas_limit = 20000000;
	m_block.coinbase = 0x7878787878787878787878787878787878787878_address;
	m_block.chain_id = 1; // Mainnet according to EIP-155.
	m_block.base_fee = 7; // The minimum value of basefee.
	m_block.blob_base_fee = evmone::state::uint256{1}; // The minimum value of blobbasefee.
	m_block.slot_number = 0xaaaaaaaa;
	m_block.prev_randao = (m_revision >= EVMC_PARIS) ?
		0xa86c2e601b6c44eb4848f7d23d9df3113fbcac42041c49cbed5000cb4f118777_bytes32 :
		intx::be::store<evmc::bytes32>(evmone::state::uint256{200000000});

	m_gasPrice = evmone::state::uint256{3000000000};
}

void EVMTransactionDriver::newBlock()
{
	++m_block.number;
	m_block.timestamp += 15;
}

void EVMTransactionDriver::reset()
{
	m_stateView.reset();
}

evmone::state::TransactionReceipt EVMTransactionDriver::run(evmone::state::Transaction const& _tx)
{
	// Validate exactly as a real node would before accepting the transaction into a block. This is
	// also where the EIP-7825 gas cap (MAX_TX_GAS_LIMIT) actually bites: ExecutionFramework's
	// InitialGas is 100000000, far above it, so callers must cap tx.gas_limit before calling run().
	std::variant<TransactionProperties, std::error_code> const validation = validate_transaction(
		m_stateView, m_block, _tx, m_revision, m_block.gas_limit, /* blob_gas_left */ 0
	);
	if (std::holds_alternative<std::error_code>(validation))
	{
		std::error_code const& error = std::get<std::error_code>(validation);
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"evmone::state::validate_transaction rejected the transaction: " + error.message()
		));
	}
	TransactionProperties const& txProps = std::get<TransactionProperties>(validation);

	// --- Probe run: capture the top-level call/create's return data. ---
	//
	// evmone::state::TransactionReceipt (populated below by the real transition()) has no output
	// field: like a real Ethereum transaction receipt, it carries status/gas/logs/state-diff but
	// not the top-level call's return data (state.cpp's transition() computes it locally as
	// `result` and simply never puts it anywhere reachable). ExecutionFramework needs those bytes
	// for every ABI_CHECK, so this probe recovers them by driving evmone::state::Host directly,
	// replicating transition()'s pre-call setup (state.cpp, roughly lines 588-647: bump the
	// sender's nonce, debit the transaction fee, build the top-level message, warm up the sender/
	// recipient/coinbase) so gas metering and the sender's balance-at-call-time match the official
	// run below precisely. EIP-7702 delegation resolution and access-list warming are not
	// replicated here: this driver never constructs `set_code` transactions or populates
	// tx.access_list, so both branches would be no-ops regardless.
	//
	// Nothing this probe touches is ever applied back to the view -- it runs against its own
	// throwaway State, seeded from the same, still-unmodified stateView() that the official
	// transition() call below also reads from -- so it cannot double-apply anything.
	bytes probeOutput;
	evmc_status_code probeStatus = EVMC_INTERNAL_ERROR;
	int64_t probeGasLeft = 0;
	int64_t probeGasRefund = 0;
	evmc::address const recipient = _tx.to.value_or(evmone::compute_create_address(_tx.sender, _tx.nonce));
	{
		State state{m_stateView};

		Account& senderAccount = state.get_or_insert(_tx.sender);
		++senderAccount.nonce;

		auto const baseFee = (m_revision >= EVMC_LONDON) ? m_block.base_fee : 0;
		auto const priorityGasPrice = std::min(_tx.max_priority_gas_price, _tx.max_gas_price - baseFee);
		auto const effectiveGasPrice = baseFee + priorityGasPrice;
		senderAccount.balance -= _tx.gas_limit * effectiveGasPrice;

		Host host{m_revision, m_vm, state, m_block, m_blockHashes, _tx};

		evmc_message message{};
		message.kind = _tx.to.has_value() ? EVMC_CALL : EVMC_CREATE;
		message.depth = 0;
		message.gas = txProps.execution_gas_limit;
		message.recipient = recipient;
		message.sender = _tx.sender;
		message.input_data = _tx.data.data();
		message.input_size = _tx.data.size();
		message.value = intx::be::store<evmc::uint256be>(_tx.value);
		message.code_address = recipient;

		senderAccount.access_status = EVMC_ACCESS_WARM;
		host.access_account(message.recipient);
		if (m_revision >= EVMC_SHANGHAI)
			host.access_account(m_block.coinbase);

		evmc::Result const result = host.call(message);
		probeStatus = result.status_code;
		probeOutput = bytes(result.output_data, result.output_data + result.output_size);
		probeGasLeft = result.gas_left;
		probeGasRefund = result.gas_refund;
	}

	// --- Official run: evmone's own, untouched bookkeeping for gas, logs and the state diff. ---
	TransactionReceipt receipt = transition(m_stateView, m_block, m_blockHashes, _tx, m_revision, m_vm, txProps);
	m_stateView.applyDiff(receipt.state_diff);

	// The probe and the official run start from identical state and perform identical pre-call
	// setup, so their outcome can only diverge if this driver's replica of that setup (above) has
	// drifted from state.cpp's real transition(). Status alone is a weak signal here -- two calls
	// can share a status code while consuming different amounts of gas (a single extra/missing
	// opcode, a warm/cold access mismatch, ...) -- so also replicate transition()'s post-call gas
	// accounting (state.cpp:651-664: the refund cap, the EIP-7623 min-gas floor, and the EIP-7778
	// block-gas-used figure) from the probe's own result.gas_left/gas_refund, and compare the
	// outcome against the two receipt fields actually derived from it.
	//
	// This still cannot catch every possible divergence: in particular, evmone::state::
	// TransactionReceipt carries no output field at all (see the module comment above), so there
	// is nothing on the official side to compare probeOutput against -- a probe that silently
	// computed the *wrong* output while still matching status/gas (e.g. a subtly wrong replica of
	// input/value/warm-up setup that happens not to affect gas metering) would go undetected here.
	int64_t const gasUsedBeforeRefund = _tx.gas_limit - probeGasLeft;
	int64_t const maxRefundQuotient = (m_revision >= EVMC_LONDON) ? 5 : 2;
	int64_t const refundLimit = gasUsedBeforeRefund / maxRefundQuotient;
	// delegation_refund (state.cpp) is always 0 here: this driver never constructs set_code
	// transactions (see the module comment above), so process_authorization_list() is a no-op on
	// both the probe and the official side.
	int64_t const refund = std::min(probeGasRefund, refundLimit);
	int64_t const expectedGasUsed = std::max(gasUsedBeforeRefund - refund, txProps.min_gas_cost);
	int64_t const expectedBlockGasUsed = std::max(gasUsedBeforeRefund, txProps.min_gas_cost);
	int64_t const expectedGasRefund = expectedBlockGasUsed - expectedGasUsed;

	soltestAssert(
		probeStatus == receipt.status,
		"evmone-state: probe and official execution produced different status codes"
	);
	soltestAssert(
		expectedGasUsed == receipt.gas_used,
		"evmone-state: probe and official execution consumed different amounts of gas"
	);
	soltestAssert(
		expectedGasRefund == receipt.gas_refund,
		"evmone-state: probe and official execution disagree on the block-gas-used refund"
	);

	m_lastOutput = std::move(probeOutput);
	m_lastRecipient = recipient;

	return receipt;
}
