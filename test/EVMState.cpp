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

#include <test/EVMState.h>

#include <test/EVMHost.h>

#include <libsolutil/Keccak256.h>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::test;

evmone::state::uint256 solidity::test::toEvmoneUint256(u256 const& _value)
{
	return intx::be::load<intx::uint256>(EVMHost::convertToEVMC(h256(_value)));
}

u256 solidity::test::fromEvmoneUint256(evmone::state::uint256 const& _value)
{
	return u256(EVMHost::convertFromEVMC(intx::be::store<evmc::bytes32>(_value)));
}

std::optional<evmone::state::StateView::Account> EVMStateView::get_account(evmc::address const& _addr) const noexcept
{
	auto it = accounts.find(_addr);
	if (it == accounts.end())
		return std::nullopt;

	evmone::state::Account const& account = it->second;
	return StateView::Account{
		account.nonce,
		account.balance,
		account.code_hash,
		!account.storage.empty()
	};
}

evmc::bytes EVMStateView::get_account_code(evmc::address const& _addr) const noexcept
{
	auto it = accounts.find(_addr);
	if (it == accounts.end())
		return {};
	return it->second.code;
}

evmc::bytes32 EVMStateView::get_storage(evmc::address const& _addr, evmc::bytes32 const& _key) const noexcept
{
	auto it = accounts.find(_addr);
	if (it == accounts.end())
		return {};

	auto storageIt = it->second.storage.find(_key);
	if (storageIt == it->second.storage.end())
		return {};
	return storageIt->second.current;
}

void EVMStateView::applyDiff(evmone::state::StateDiff const& _diff)
{
	for (evmone::state::StateDiff::Entry const& entry: _diff.modified_accounts)
	{
		evmone::state::Account& account = accounts[entry.addr];
		account.nonce = entry.nonce;
		account.balance = entry.balance;

		if (entry.code.has_value())
		{
			account.code = *entry.code;
			account.code_hash = entry.code->empty() ?
				evmone::state::Account::EMPTY_CODE_HASH :
				EVMHost::convertToEVMC(keccak256(bytesConstRef(entry.code->data(), entry.code->size())));
		}

		for (auto const& [key, value]: entry.modified_storage)
		{
			// A zero value means the slot was cleared, not "set to zero": mirror evmone's own
			// reference applier (evmone's test/utils/test_state.cpp TestState::apply(), matching
			// the convention documented in test/state/state_diff.hpp) by erasing the entry rather
			// than storing a zero-valued one. Leaving a stale zero entry behind would make
			// get_account() below report has_storage = true forever, which State::find() copies
			// into Account::has_initial_storage and is_create_collision() (evmone's
			// test/state/host.cpp) then treats as a CREATE2 collision even though a real,
			// currently-empty account would not collide.
			if (value)
			{
				evmone::state::StorageValue& slot = account.storage[key];
				// The transaction that produced this diff has already committed: the new value is
				// both the current and (for the next transaction) the original value, the same
				// reset EVMHost::newTransactionFrame() performs on every account's storage.
				slot.current = value;
				slot.original = value;
				slot.access_status = EVMC_ACCESS_COLD;
			}
			else
				account.storage.erase(key);
		}
	}

	for (evmc::address const& addr: _diff.deleted_accounts)
		accounts.erase(addr);
}

void EVMStateView::reset()
{
	accounts.clear();
}

evmc::bytes32 EVMBlockHashes::get_block_hash(int64_t _number) const noexcept
{
	// Matches EVMHost::get_block_hash() exactly, so BLOCKHASH is comparable between the two paths.
	return EVMHost::convertToEVMC(u256("0x3737373737373737373737373737373737373737373737373737373737373737") + _number);
}
