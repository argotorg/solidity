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
 * Unit tests for EVMStateView, in particular applyDiff().
 */

#include <test/EVMState.h>

#include <test/EVMHost.h>

#include <boost/test/unit_test.hpp>

using namespace solidity::test;

namespace solidity::test
{

BOOST_AUTO_TEST_SUITE(EVMStateTest, *boost::unit_test::label("nooptions"))

// A storage slot written and then cleared back to zero within (or across) transactions must not
// leave a stale zero-valued entry behind. evmone's own reference applier (TestState::apply() in
// evmone's test/utils/test_state.cpp) erases a slot outright when the diff carries a zero value
// for it, exactly matching the convention documented in evmone's test/state/state_diff.hpp
// ("The value 0 means the storage entry is deleted."). EVMStateView::applyDiff() must do the same:
// EVMStateView::get_account() reports has_storage as !account.storage.empty(), which evmone's
// State::find() (test/state/state.cpp) copies into Account::has_initial_storage, and
// is_create_collision() (test/state/host.cpp) treats a true has_initial_storage as collision-
// triggering for CREATE/CREATE2 -- regardless of the actual (zero) value left behind. A stale
// zero entry would therefore make a later CREATE2 to that address spuriously collide, where real
// EVM semantics (an account with no code, no nonce, and empty storage) would permit it.
BOOST_AUTO_TEST_CASE(applyDiff_erases_zero_valued_storage_slots)
{
	EVMStateView state;
	evmc::address const addr = EVMHost::convertToEVMC(util::h160("0x0000000000000000000000000000000000004242"));
	evmc::bytes32 const key{1};
	evmc::bytes32 const nonZeroValue{7};

	// First transaction's diff: the slot is written to a non-zero value (e.g. a constructor
	// storing to a state variable).
	evmone::state::StateDiff diff1;
	evmone::state::StateDiff::Entry entry1;
	entry1.addr = addr;
	entry1.nonce = 1;
	entry1.balance = {};
	entry1.modified_storage.push_back({key, nonZeroValue});
	diff1.modified_accounts.push_back(entry1);
	state.applyDiff(diff1);

	BOOST_REQUIRE_EQUAL(state.accounts.count(addr), 1);
	BOOST_REQUIRE(state.get_account(addr).has_value());
	BOOST_CHECK(state.get_account(addr)->has_storage);
	BOOST_CHECK(state.get_storage(addr, key) == nonZeroValue);

	// Second transaction's diff: the very same slot is written back to zero (e.g. `delete` on
	// that state variable, or a SSTORE of 0).
	evmone::state::StateDiff diff2;
	evmone::state::StateDiff::Entry entry2;
	entry2.addr = addr;
	entry2.nonce = 1;
	entry2.balance = {};
	entry2.modified_storage.push_back({key, evmc::bytes32{}});
	diff2.modified_accounts.push_back(entry2);
	state.applyDiff(diff2);

	// The slot must be gone, not merely zeroed, and the account must report empty storage --
	// exactly what is_create_collision() (evmone's test/state/host.cpp) relies on to allow a
	// later CREATE2 to this address.
	BOOST_CHECK(state.accounts.at(addr).storage.empty());
	BOOST_REQUIRE(state.get_account(addr).has_value());
	BOOST_CHECK(!state.get_account(addr)->has_storage);
	BOOST_CHECK(state.get_storage(addr, key) == evmc::bytes32{});
}

BOOST_AUTO_TEST_SUITE_END()

}
