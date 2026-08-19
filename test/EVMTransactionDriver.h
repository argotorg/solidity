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
 * MVP driver that runs transactions through evmone::state::transition() -- evmone's own
 * state-transition library -- instead of the hand-written EVMHost. See the module comment in
 * EVMTransactionDriver.cpp for how it works around evmone::state::TransactionReceipt not carrying
 * the top-level call's return data.
 */

#pragma once

#include <test/EVMState.h>

#include <test/state/state.hpp>

#include <evmc/evmc.hpp>

#include <liblangutil/EVMVersion.h>

#include <libsolutil/Common.h>

namespace solidity::test
{

class EVMTransactionDriver
{
public:
	EVMTransactionDriver(langutil::EVMVersion _evmVersion, evmc::VM& _vm);

	/// Validates and executes @a _tx against the current state, then applies the resulting
	/// StateDiff to stateView(). Throws std::runtime_error, with evmone's own rejection message,
	/// if evmone::state::validate_transaction() rejects the transaction -- most likely because of
	/// the EIP-7825 gas-limit cap; see ExecutionFramework::InitialGas and MAX_TX_GAS_LIMIT.
	evmone::state::TransactionReceipt run(evmone::state::Transaction const& _tx);

	/// Starts a new block. Mirrors EVMHost::newBlock()'s block_number++ / block_timestamp += 15;
	/// unlike EVMHost, there is no per-block bookkeeping to clear -- transition() builds a fresh
	/// evmone::state::State for every run(), so EIP-2929 warm/cold status never survives between
	/// transactions here even without an explicit reset.
	void newBlock();

	/// Resets to the empty state (the accounts map only; the block context set up by the
	/// constructor is left as is, matching how EVMHost::reset() leaves tx_context alone).
	void reset();

	EVMStateView& stateView() { return m_stateView; }
	EVMStateView const& stateView() const { return m_stateView; }

	evmone::state::BlockInfo const& blockInfo() const { return m_block; }

	/// The gas price every transaction built against this driver should use, mirroring EVMHost's
	/// fixed tx_context.tx_gas_price.
	evmone::state::uint256 const& gasPrice() const { return m_gasPrice; }

	/// The return data of the most recent run()'s top-level call/create. Not part of
	/// evmone::state::TransactionReceipt -- see EVMTransactionDriver.cpp for why.
	bytes const& lastOutput() const { return m_lastOutput; }

	/// The address run()'s top-level call actually executed against: for a call, this is simply
	/// the transaction's `to`; for a create, it is the address evmone derived from the sender and
	/// nonce (the CREATE scheme), which the caller cannot otherwise recompute without depending on
	/// evmone's internal, non-exported build_message().
	evmc::address lastRecipient() const { return m_lastRecipient; }

private:
	evmc::VM& m_vm;
	evmc_revision m_revision;
	EVMStateView m_stateView;
	EVMBlockHashes m_blockHashes;
	evmone::state::BlockInfo m_block;
	evmone::state::uint256 m_gasPrice;
	bytes m_lastOutput;
	evmc::address m_lastRecipient{};
};

}
