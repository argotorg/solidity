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
 * Unit tests for EVMHost.
 */

#include <test/EVMHost.h>

#include <boost/test/unit_test.hpp>

#include <algorithm>
#include <sstream>
#include <vector>

namespace solidity::test
{

BOOST_AUTO_TEST_SUITE(EVMHostTest, *boost::unit_test::label("nooptions"))

// Cross-checked against evmone's own compute_create_address() unit tests
// (test/unittests/create_address_test.cpp, TEST(create_address, create_nonces) and
// TEST(create_address, create_examples) in evmone 0.23.0), which is the RLP/keccak
// derivation the EVMC 18 VM actually performs for CREATE.
BOOST_AUTO_TEST_CASE(compute_create_address)
{
	util::h160 const sender0("0x0000000000000000000000000000000000000000");
	util::h160 const sender1("0x0000000000000000000000000000000000000001");

	// Nonce 0: RLP empty string (0x80).
	BOOST_CHECK_EQUAL(
		EVMHost::computeCreateAddress(EVMHost::convertToEVMC(sender0), 0),
		util::h160("0xbd770416a3345f91e4b34576cb804a576fa48eb1")
	);

	// Nonce 1..127: RLP single byte, no prefix.
	BOOST_CHECK_EQUAL(
		EVMHost::computeCreateAddress(EVMHost::convertToEVMC(sender1), 1),
		util::h160("0x535b3d7a252fa034ed71f0c53ec0c6f784cb64e1")
	);

	// Nonce 128..255: RLP short-string, 1-byte payload (prefix 0x81).
	BOOST_CHECK_EQUAL(
		EVMHost::computeCreateAddress(EVMHost::convertToEVMC(sender1), 0x80),
		util::h160("0x09c1ef8f55c61b94e8b92a55d0891d408a991e18")
	);

	// Nonce 256..65535: RLP short-string, 2-byte payload (prefix 0x82). This is exactly
	// the case that used to be miscomputed with the "long string" prefix 0xb9 instead of
	// the correct "short string" prefix 0x82.
	BOOST_CHECK_EQUAL(
		EVMHost::computeCreateAddress(EVMHost::convertToEVMC(sender0), 0x100),
		util::h160("0x1183a5a83c1fa113618603abc4509077ec672699")
	);
	BOOST_CHECK_EQUAL(
		EVMHost::computeCreateAddress(EVMHost::convertToEVMC(sender0), 0xffff),
		util::h160("0xae80be2f887b0efb148934160afd38459969571a")
	);

	// Nonce beyond 0xffff: previously unsupported (solUnimplemented). Now handled via
	// minimal big-endian encoding, with a 4-byte and an 8-byte (full uint64_t range) payload.
	BOOST_CHECK_EQUAL(
		EVMHost::computeCreateAddress(EVMHost::convertToEVMC(sender0), 0xffffffff),
		util::h160("0x83317d2df02af8fe91040765f49719e8115c0f04")
	);
	BOOST_CHECK_EQUAL(
		EVMHost::computeCreateAddress(EVMHost::convertToEVMC(sender0), 0xffffffffffffffffULL),
		util::h160("0x1262d73ea59d3a661bf8751d16cf1a5377149e75")
	);
}

// EVMHostPrinter::storage() must produce deterministic, key-sorted output, even though upstream
// evmc::MockedHost's MockedAccount::storage (test/EVMHost.h's StorageMap is built from it in
// EVMHost::get_address_storage()) is an unordered_map, not the std::map the vendored
// test/evmc/mocked_host.hpp used to declare it as (PR #11094, for deterministic fuzzing output).
// That vendored tweak is gone now that mocked_host.hpp comes from upstream evmone unmodified;
// EVMHost::get_address_storage() sorting at the point of output is what preserves the guarantee
// instead. This is the only place that guarantee is checked: EVMHostPrinter is otherwise only
// ever instantiated from test/tools/ossfuzz/StackReuseCodegenFuzzer.cpp, and building OSSFUZZ
// targets requires libprotobuf-mutator and clang++, neither available in this environment.
BOOST_AUTO_TEST_CASE(storage_printer_output_is_sorted)
{
	EVMHost host(langutil::EVMVersion{}, EVMHost::getVM());
	evmc::address const addr =
		EVMHost::convertToEVMC(util::h160("0x0000000000000000000000000000000000004242"));

	// Keys are spread across the full 64-bit range (not just a single low byte) and inserted in
	// an order unrelated to their numeric value, so that a test relying on insertion order or on
	// std::hash<evmc::bytes32>'s FNV1a-folded bucket order (evmc/evmc.hpp) -- rather than on an
	// actual sort -- would have no reason to come out sorted by coincidence.
	std::vector<uint64_t> const keysInInsertionOrder = {
		0xfedcba9876543210ULL, 0x1ULL,       0x8000000000000000ULL, 0x0123456789abcdefULL,
		0x2ULL,                0xffffffffffffffffULL, 0x5555555555555555ULL, 0x3ULL,
		0xaaaaaaaaaaaaaaaaULL, 0x0ULL,       0xdeadbeefdeadbeefULL, 0x4ULL,
		0xcafebabecafebabeULL, 0x123ULL,     0x9999999999999999ULL, 0x5ULL
	};
	// A fixed, unrelated non-zero value for every slot: a storage slot whose *current* value is
	// zero is treated as unset and filtered out by EVMHostPrinter::storage(), and deriving the
	// value from the key (e.g. key + 1) risks silently wrapping back to zero for a key at the
	// top of the range -- exactly what 0xffff...ffff + 1 does.
	evmc::bytes32 const value{0xabcdefULL};
	for (uint64_t key: keysInInsertionOrder)
		host.set_storage(addr, evmc::bytes32{key}, value);

	std::vector<uint64_t> expectedSortedKeys = keysInInsertionOrder;
	std::sort(expectedSortedKeys.begin(), expectedSortedKeys.end());

	std::string const printed = EVMHostPrinter{host, addr}.state();
	std::istringstream printedStream(printed);
	std::vector<std::string> storageLines;
	std::string line;
	// Storage lines are printed first, each indented by exactly two spaces; the unindented
	// "BALANCE ..." line that always follows marks the end of the storage section.
	while (std::getline(printedStream, line) && line.substr(0, 2) == "  ")
		storageLines.push_back(line);

	BOOST_REQUIRE_EQUAL(storageLines.size(), expectedSortedKeys.size());
	for (size_t i = 0; i < expectedSortedKeys.size(); i++)
	{
		std::ostringstream expectedLine;
		expectedLine << "  "
			<< EVMHost::convertFromEVMC(evmc::bytes32{expectedSortedKeys[i]})
			<< ": "
			<< EVMHost::convertFromEVMC(value);
		BOOST_CHECK_EQUAL(storageLines[i], expectedLine.str());
	}
}

BOOST_AUTO_TEST_SUITE_END()

}
