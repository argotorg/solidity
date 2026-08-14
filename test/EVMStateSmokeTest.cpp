#include <test/state/transaction.hpp>

#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_SUITE(EVMStateSmokeTest)

BOOST_AUTO_TEST_CASE(state_library_links)
{
	// decode_transaction() is defined in transaction.cpp, so this only builds and runs
	// if evmone-state's object code is actually linked in. A single 0x00 byte is neither an RLP
	// list (the legacy transaction encoding) nor a valid EIP-2718 type byte: 0x00 is reserved for
	// Transaction::Type::legacy, and decode_transaction_body() explicitly rejects that value in the
	// typed-transaction branch (transaction.cpp), so this must be rejected.
	auto const decoded = evmone::state::decode_transaction(evmc::bytes{0x00});
	BOOST_CHECK(!decoded.has_value());
}

BOOST_AUTO_TEST_SUITE_END()
