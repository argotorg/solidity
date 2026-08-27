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
 * An in-memory evmone::state::StateView, the read side of the MVP that drives transactions
 * through evmone::state::transition() instead of the hand-written EVMHost. See
 * EVMTransactionDriver.h for the part that actually runs transactions against this view.
 */

#pragma once

#include <test/state/account.hpp>
#include <test/state/state_diff.hpp>
#include <test/state/state_view.hpp>

#include <evmc/evmc.hpp>

#include <libsolutil/Numeric.h>

#include <map>

namespace solidity::test
{

/// Converts Solidity's own big integer type to the 256-bit integer evmone::state uses
/// throughout (intx::uint256, imported into evmone::state as `evmone::state::uint256`).
evmone::state::uint256 toEvmoneUint256(u256 const& _value);

/// The inverse of toEvmoneUint256().
u256 fromEvmoneUint256(evmone::state::uint256 const& _value);

/// In-memory evmone::state::StateView, backed by a std::map<evmc::address, evmone::state::Account>
/// -- the same per-account representation (nonce, balance, code, code_hash, storage all together)
/// evmone's own State keeps internally, and structurally the same shape as EVMHost's own
/// (evmc::MockedHost::)accounts map.
///
/// Kept ordered (std::map, not the unordered_map evmone's own State uses) for the same reason
/// EVMHost::get_address_storage builds a sorted copy rather than exposing MockedAccount::storage
/// directly: deterministic iteration for anything that prints this state.
class EVMStateView: public evmone::state::StateView
{
public:
	std::map<evmc::address, evmone::state::Account> accounts;

	std::optional<Account> get_account(evmc::address const& _addr) const noexcept override;
	evmc::bytes get_account_code(evmc::address const& _addr) const noexcept override;
	evmc::bytes32 get_storage(evmc::address const& _addr, evmc::bytes32 const& _key) const noexcept override;

	/// Applies a StateDiff, as returned in evmone::state::TransactionReceipt::state_diff, to
	/// accounts. Mirrors evmone::state::State::build_diff()'s semantics (state.cpp): each
	/// modified_accounts entry carries the account's final nonce and balance (not deltas), an
	/// optional replacement for the account's entire code (absent means "unchanged", empty means
	/// "cleared"), and the final value of every storage slot the transaction touched. Accounts
	/// named in deleted_accounts are erased outright.
	void applyDiff(evmone::state::StateDiff const& _diff);

	/// Resets to the empty state, mirroring EVMHost::reset() clearing MockedHost::accounts.
	/// Unlike EVMHost::reset(), this does not pre-populate the precompile addresses (1..8) with a
	/// balance: evmone's own precompile dispatch (is_precompile()) recognises them purely by
	/// address and revision, independent of anything in the state.
	void reset();
};

/// evmone::state::BlockHashes returning the same synthetic hash EVMHost::get_block_hash() does,
/// so BLOCKHASH is comparable between the two paths.
class EVMBlockHashes: public evmone::state::BlockHashes
{
public:
	evmc::bytes32 get_block_hash(int64_t _number) const noexcept override;
};

}
