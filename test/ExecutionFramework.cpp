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
 * @author Christian <c@ethdev.com>
 * @date 2016
 * Framework for executing contracts and testing them using RPC.
 */

#include <test/ExecutionFramework.h>

#include <test/EVMHost.h>

#include <evmc/evmc.hpp>

#include <test/libsolidity/util/SoltestTypes.h>

#include <libevmasm/GasMeter.h>

#include <libsolutil/CommonIO.h>

#include <liblangutil/Exceptions.h>

#include <boost/test/framework.hpp>
#include <boost/algorithm/string/replace.hpp>
#include <range/v3/range.hpp>
#include <range/v3/view/transform.hpp>

#include <cstdlib>
#include <limits>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::test;
using namespace solidity::frontend::test;

ExecutionFramework::ExecutionFramework():
	ExecutionFramework(solidity::test::CommonOptions::get().evmVersion(), solidity::test::CommonOptions::get().vmPaths)
{
}

ExecutionFramework::ExecutionFramework(langutil::EVMVersion _evmVersion, std::vector<boost::filesystem::path> const& _vmPaths):
	m_evmVersion(_evmVersion),
	m_optimiserSettings(solidity::frontend::OptimiserSettings::minimal()),
	m_showMessages(solidity::test::CommonOptions::get().showMessages),
	m_vmPaths(_vmPaths)
{
	if (solidity::test::CommonOptions::get().optimize)
		m_optimiserSettings = solidity::frontend::OptimiserSettings::standard();
	selectVM();
}

void ExecutionFramework::selectVM()
{
	m_evmcHost.reset();
	m_stateDriver.reset();
	bool const useEvmoneState = solidity::test::CommonOptions::get().useEvmoneState;
	for (auto const& path: m_vmPaths)
	{
		evmc::VM& vm = EVMHost::getVM(path.string());
		if (vm)
		{
			if (useEvmoneState)
				m_stateDriver = std::make_unique<EVMTransactionDriver>(m_evmVersion, vm);
			else
				m_evmcHost = std::make_unique<EVMHost>(m_evmVersion, vm);
			break;
		}
	}
	solAssert(m_evmcHost != nullptr || m_stateDriver != nullptr, "");
	reset();
}

void ExecutionFramework::reset()
{
	if (m_stateDriver)
	{
		m_stateDriver->reset();
		for (size_t i = 0; i < 10; i++)
		{
			evmone::state::Account& account = m_stateDriver->stateView().accounts[EVMHost::convertToEVMC(this->account(i))];
			account.balance = toEvmoneUint256(u256(1) << 100);
			// The first CREATE from a test account must derive its address from nonce 1, matching
			// what this framework produced when EVMHost pre-incremented before deriving.
			account.nonce = 1;
		}
		return;
	}

	m_evmcHost->reset();
	for (size_t i = 0; i < 10; i++)
	{
		auto& account = m_evmcHost->accounts[EVMHost::convertToEVMC(this->account(i))];
		account.balance = EVMHost::convertToEVMC(u256(1) << 100);
		// The first CREATE from a test account must derive its address from nonce 1, matching
		// what this framework produced when EVMHost pre-incremented before deriving.
		account.nonce = 1;
	}
}

std::pair<bool, std::string> ExecutionFramework::compareAndCreateMessage(
	bytes const& _result,
	bytes const& _expectation
)
{
	if (_result == _expectation)
		return std::make_pair(true, std::string{});
	std::string message =
			"Invalid encoded data\n"
			"   Result                                                           Expectation\n";
	auto resultHex = boost::replace_all_copy(util::toHex(_result), "0", ".");
	auto expectedHex = boost::replace_all_copy(util::toHex(_expectation), "0", ".");
	for (size_t i = 0; i < std::max(resultHex.size(), expectedHex.size()); i += 0x40)
	{
		std::string result{i >= resultHex.size() ? std::string{} : resultHex.substr(i, 0x40)};
		std::string expected{i > expectedHex.size() ? std::string{} : expectedHex.substr(i, 0x40)};
		message +=
			(result == expected ? "   " : " X ") +
			result +
			std::string(0x41 - result.size(), ' ') +
			expected +
			"\n";
	}
	return make_pair(false, message);
}

bytes ExecutionFramework::panicData(util::PanicCode _code)
{
	return
		m_evmVersion.supportsReturndata() ?
		toCompactBigEndian(selectorFromSignatureU32("Panic(uint256)"), 4) + encode(u256(static_cast<unsigned>(_code))) :
		bytes();
}

u256 ExecutionFramework::gasLimit() const
{
	if (m_stateDriver)
		return u256(m_stateDriver->blockInfo().gas_limit);
	return {m_evmcHost->tx_context.block_gas_limit};
}

u256 ExecutionFramework::gasPrice() const
{
	// here and below we use "return u256{....}" instead of just "return {....}"
	// to please MSVC and avoid unexpected
	// warning C4927 : illegal conversion; more than one user - defined conversion has been implicitly applied
	if (m_stateDriver)
		return fromEvmoneUint256(m_stateDriver->gasPrice());
	return u256{EVMHost::convertFromEVMC(m_evmcHost->tx_context.tx_gas_price)};
}

u256 ExecutionFramework::blockHash(u256 const& _number) const
{
	int64_t const number = static_cast<int64_t>(_number & std::numeric_limits<uint64_t>::max());
	if (m_stateDriver)
		return u256{EVMHost::convertFromEVMC(EVMBlockHashes{}.get_block_hash(number))};
	return u256{EVMHost::convertFromEVMC(m_evmcHost->get_block_hash(number))};
}

u256 ExecutionFramework::blockNumber() const
{
	if (m_stateDriver)
		return u256(m_stateDriver->blockInfo().number);
	return m_evmcHost->tx_context.block_number;
}

evmone::state::Transaction ExecutionFramework::buildStateTransaction(
	std::optional<evmc::address> const& _to,
	bytes const& _data,
	u256 const& _value
) const
{
	evmone::state::Transaction tx;
	tx.sender = EVMHost::convertToEVMC(m_sender);
	tx.to = _to;
	tx.data = evmc::bytes(_data.begin(), _data.end());
	tx.value = toEvmoneUint256(_value);
	// EIP-7825 caps transaction gas at MAX_TX_GAS_LIMIT (16777216); InitialGas (100000000) exceeds
	// it. evmone's own validate_transaction() only enforces this cap from EVMC_OSAKA onwards
	// (test/state/state.cpp: `if (rev >= EVMC_OSAKA && tx.gas_limit > MAX_TX_GAS_LIMIT) ...`), so
	// only gate InitialGas down when running at Osaka or later; below that, real chain semantics
	// impose no such ceiling, and the mock-Host path (EVMHost.cpp) never applied one either.
	tx.gas_limit = (
		m_evmVersion >= langutil::EVMVersion::osaka() ?
		std::min(InitialGas, u256(evmone::state::MAX_TX_GAS_LIMIT)) :
		InitialGas
	).convert_to<int64_t>();
	tx.max_gas_price = m_stateDriver->gasPrice();
	tx.max_priority_gas_price = m_stateDriver->gasPrice();
	tx.chain_id = m_stateDriver->blockInfo().chain_id;
	if (std::optional<evmone::state::StateView::Account> account = m_stateDriver->stateView().get_account(tx.sender))
		tx.nonce = account->nonce;
	return tx;
}

void ExecutionFramework::sendMessage(bytes const& _bytecode, bytes const& _arguments, bool _isCreation, u256 const& _value)
{
	if (m_stateDriver)
	{
		m_stateDriver->newBlock();

		auto const data = _bytecode + _arguments;

		if (m_showMessages)
		{
			if (_isCreation)
				std::cout << "CREATE " << m_sender.hex() << ":" << std::endl;
			else
				std::cout << "CALL   " << m_sender.hex() << " -> " << m_contractAddress.hex() << ":" << std::endl;
			if (_value > 0)
				std::cout << " value: " << _value << std::endl;
			std::cout << " in:      " << util::toHex(data) << std::endl;
		}

		evmone::state::Transaction const tx = buildStateTransaction(
			_isCreation ? std::nullopt : std::optional<evmc::address>(EVMHost::convertToEVMC(m_contractAddress)),
			data,
			_value
		);

		m_lastStateReceipt = m_stateDriver->run(tx);

		if (_isCreation)
		{
			m_contractAddress = EVMHost::convertFromEVMC(m_stateDriver->lastRecipient());
			// Unlike EVMHost::call() (which never clears result.output_data, so a successful
			// creation transaction's "output" is the constructor's RETURN bytes, i.e. the
			// deployed code), evmone::state::Host::create() returns a *fresh*, output-less
			// Result on success (host.cpp) -- the deployed code lives only in the account, not
			// in the call result. On failure (revert/OOG) it returns the original result
			// untouched, so lastOutput() (this driver's probe capture) still carries the revert
			// reason correctly in that case. Match EVMHost's observable contract either way.
			if (m_lastStateReceipt.status == EVMC_SUCCESS)
			{
				evmc::bytes const code = m_stateDriver->stateView().get_account_code(m_stateDriver->lastRecipient());
				m_output = bytes(code.begin(), code.end());
			}
			else
				m_output = m_stateDriver->lastOutput();
		}
		else
			m_output = m_stateDriver->lastOutput();

		// evmone::state::TransactionReceipt::gas_used is already net of refund and floored at the
		// EIP-7623 minimum, unlike EVMHost's InitialGas-relative computation below.
		m_gasUsed = u256(m_lastStateReceipt.gas_used);
		// Reconstructed from the StateDiff rather than hard-coded to 0: State::build_diff() (in
		// evmone's state.cpp) only populates Entry::code when that account's code_changed, i.e.
		// exactly when a CREATE/CREATE2 within this transaction deployed new code, at any call
		// depth -- the same "every newly created contract in the transaction" scope
		// EVMHost::m_totalCodeDepositGas sums over (see EVMHost.cpp).
		//
		// A failed creation (revert/OOG/...) leaves no code in the diff, so it contributes 0 here
		// -- and that is a deliberate divergence from EVMHost::m_totalCodeDepositGas, not a gap to
		// close. evmone's own Host::create() (evmone's test/state/host.cpp:222) returns immediately
		// on a non-EVMC_SUCCESS init-code result, *before* ever computing a code-deposit charge;
		// that charge (host.cpp:238-246, `createDataGas * code.size()`) only exists on the success
		// path, and `code` there is the actual deployed bytecode. EVMHost.cpp's
		// message.kind == EVMC_CREATE/EVMC_CREATE2 branch (~lines 412-429) instead computes
		// `codeDepositGas` from `result.output_size` unconditionally -- on a reverted creation,
		// `result.output_size` is the length of the revert-reason bytes, not deployed code, so
		// EVMHost charges code-deposit gas for bytes that were never, and were never going to be,
		// stored as code. Worse, that charge lands in m_totalCodeDepositGas, a running counter
		// EVMHost::call() never rolls back even though it does roll back `accounts` on failure
		// (the `if (result.status_code != EVMC_SUCCESS) accounts = stateBackup;` a few lines
		// below it) -- so the mis-charge is permanent for the rest of the run. Charging
		// code-deposit gas for revert-reason bytes is not real EVM semantics; evmone's behaviour
		// (and this reconstruction's) is the correct one. See EVMHost.cpp for the mock-Host side of
		// this if it ever needs equivalent fixing.
		m_gasUsedForCodeDeposit = 0;
		for (evmone::state::StateDiff::Entry const& entry: m_lastStateReceipt.state_diff.modified_accounts)
			if (entry.code.has_value())
				m_gasUsedForCodeDeposit += u256(entry.code->size()) * evmasm::GasCosts::createDataGas;
		m_transactionSuccessful = (m_lastStateReceipt.status == EVMC_SUCCESS);

		if (m_showMessages)
		{
			std::cout << " out:                       " << util::toHex(m_output) << std::endl;
			std::cout << " result:                    " << static_cast<size_t>(m_lastStateReceipt.status) << std::endl;
			std::cout << " gas used:                  " << m_gasUsed.str() << std::endl;
		}
		return;
	}

	m_evmcHost->newBlock();

	auto const data = _bytecode + _arguments;

	if (m_showMessages)
	{
		if (_isCreation)
			std::cout << "CREATE " << m_sender.hex() << ":" << std::endl;
		else
			std::cout << "CALL   " << m_sender.hex() << " -> " << m_contractAddress.hex() << ":" << std::endl;
		if (_value > 0)
			std::cout << " value: " << _value << std::endl;
		std::cout << " in:      " << util::toHex(data) << std::endl;
	}
	evmc_message message{};
	message.input_data = data.data();
	message.input_size = data.size();
	message.sender = EVMHost::convertToEVMC(m_sender);
	message.value = EVMHost::convertToEVMC(_value);

	if (_isCreation)
	{
		message.kind = EVMC_CREATE;
		message.recipient = EVMHost::convertToEVMC(
			EVMHost::computeCreateAddress(message.sender, m_evmcHost->get_nonce(message.sender))
		);
		message.code_address = {};
	}
	else
	{
		message.kind = EVMC_CALL;
		message.recipient = EVMHost::convertToEVMC(m_contractAddress);
		message.code_address = message.recipient;
	}

	message.gas = InitialGas.convert_to<int64_t>();

	evmc::Result result = m_evmcHost->call(message);

	m_output = bytes(result.output_data, result.output_data + result.output_size);
	if (_isCreation)
		m_contractAddress = EVMHost::convertFromEVMC(message.recipient);

	unsigned const refundRatio = (m_evmVersion >= langutil::EVMVersion::london() ? 5 : 2);
	auto const totalGasUsed = InitialGas - result.gas_left;
	auto const gasRefund = std::min(u256(result.gas_refund), totalGasUsed / refundRatio);

	m_gasUsed = totalGasUsed - gasRefund;
	m_gasUsedForCodeDeposit = m_evmcHost->totalCodeDepositGas();
	m_transactionSuccessful = (result.status_code == EVMC_SUCCESS);

	if (m_showMessages)
	{
		std::cout << " out:                       " << util::toHex(m_output) << std::endl;
		std::cout << " result:                    " << static_cast<size_t>(result.status_code) << std::endl;
		std::cout << " gas used:                  " << m_gasUsed.str() << std::endl;
		std::cout << " gas used (without refund): " << totalGasUsed.str() << std::endl;
		std::cout << "     code deposits only:    " << m_gasUsedForCodeDeposit.str() << std::endl;
		std::cout << " gas refund (total):        " << result.gas_refund << std::endl;
		std::cout << " gas refund (bound):        " << gasRefund.str() << std::endl;
	}
}

void ExecutionFramework::sendEther(h160 const& _addr, u256 const& _amount)
{
	if (m_stateDriver)
	{
		m_stateDriver->newBlock();
		evmone::state::Transaction const tx = buildStateTransaction(EVMHost::convertToEVMC(_addr), bytes(), _amount);
		m_stateDriver->run(tx);
		return;
	}

	m_evmcHost->newBlock();

	if (m_showMessages)
	{
		std::cout << "SEND_ETHER   " << m_sender.hex() << " -> " << _addr.hex() << ":" << std::endl;
		if (_amount > 0)
			std::cout << " value: " << _amount << std::endl;
	}
	evmc_message message{};
	message.sender = EVMHost::convertToEVMC(m_sender);
	message.value = EVMHost::convertToEVMC(_amount);
	message.kind = EVMC_CALL;
	message.recipient = EVMHost::convertToEVMC(_addr);
	message.code_address = message.recipient;
	message.gas = InitialGas.convert_to<int64_t>();

	m_evmcHost->call(message);
}

size_t ExecutionFramework::currentTimestamp()
{
	if (m_stateDriver)
		return static_cast<size_t>(m_stateDriver->blockInfo().timestamp);
	return static_cast<size_t>(m_evmcHost->tx_context.block_timestamp);
}

size_t ExecutionFramework::blockTimestamp(u256 _block)
{
	if (_block > blockNumber())
		return 0;
	else
		return static_cast<size_t>((currentTimestamp() / blockNumber()) * _block);
}

h160 ExecutionFramework::account(size_t _idx)
{
	return h160(h256(u256{"0x1212121212121212121212121212120000000012"} + _idx * 0x1000), h160::AlignRight);
}

bool ExecutionFramework::addressHasCode(h160 const& _addr) const
{
	if (m_stateDriver)
		return !m_stateDriver->stateView().get_account_code(EVMHost::convertToEVMC(_addr)).empty();
	return m_evmcHost->get_code_size(EVMHost::convertToEVMC(_addr)) != 0;
}

size_t ExecutionFramework::numLogs() const
{
	if (m_stateDriver)
		return m_lastStateReceipt.logs.size();
	return m_evmcHost->recorded_logs.size();
}

size_t ExecutionFramework::numLogTopics(size_t _logIdx) const
{
	if (m_stateDriver)
		return m_lastStateReceipt.logs.at(_logIdx).topics.size();
	return m_evmcHost->recorded_logs.at(_logIdx).topics.size();
}

h256 ExecutionFramework::logTopic(size_t _logIdx, size_t _topicIdx) const
{
	if (m_stateDriver)
		return EVMHost::convertFromEVMC(m_lastStateReceipt.logs.at(_logIdx).topics.at(_topicIdx));
	return EVMHost::convertFromEVMC(m_evmcHost->recorded_logs.at(_logIdx).topics.at(_topicIdx));
}

h160 ExecutionFramework::logAddress(size_t _logIdx) const
{
	if (m_stateDriver)
		return EVMHost::convertFromEVMC(m_lastStateReceipt.logs.at(_logIdx).addr);
	return EVMHost::convertFromEVMC(m_evmcHost->recorded_logs.at(_logIdx).creator);
}

bytes ExecutionFramework::logData(size_t _logIdx) const
{
	// TODO: Return a copy of log data, because this is expected from REQUIRE_LOG_DATA(),
	//       but reference type like string_view would be preferable.
	if (m_stateDriver)
	{
		auto const& data = m_lastStateReceipt.logs.at(_logIdx).data;
		return {data.begin(), data.end()};
	}
	auto const& data = m_evmcHost->recorded_logs.at(_logIdx).data;
	return {data.begin(), data.end()};
}

u256 ExecutionFramework::balanceAt(h160 const& _addr) const
{
	if (m_stateDriver)
	{
		auto const& accounts = m_stateDriver->stateView().accounts;
		auto const it = accounts.find(EVMHost::convertToEVMC(_addr));
		return it == accounts.end() ? u256(0) : fromEvmoneUint256(it->second.balance);
	}
	return u256(EVMHost::convertFromEVMC(m_evmcHost->get_balance(EVMHost::convertToEVMC(_addr))));
}

bool ExecutionFramework::storageEmpty(h160 const& _addr) const
{
	if (m_stateDriver)
	{
		auto const& accounts = m_stateDriver->stateView().accounts;
		auto const it = accounts.find(EVMHost::convertToEVMC(_addr));
		if (it != accounts.end())
			for (auto const& entry: it->second.storage)
				if (entry.second.current != evmc::bytes32{})
					return false;
		return true;
	}

	const auto it = m_evmcHost->accounts.find(EVMHost::convertToEVMC(_addr));
	if (it != m_evmcHost->accounts.end())
	{
		for (auto const& entry: it->second.storage)
			if (entry.second.current != evmc::bytes32{})
				return false;
	}
	return true;
}

std::vector<solidity::frontend::test::LogRecord> ExecutionFramework::recordedLogs() const
{
	std::vector<LogRecord> logs;
	if (m_stateDriver)
	{
		for (evmone::state::Log const& log: m_lastStateReceipt.logs)
			logs.emplace_back(
				EVMHost::convertFromEVMC(log.addr),
				bytes{log.data.begin(), log.data.end()},
				log.topics | ranges::views::transform([](evmc::bytes32 _bytes) { return EVMHost::convertFromEVMC(_bytes); }) | ranges::to<std::vector>
			);
		return logs;
	}
	for (evmc::MockedHost::log_record const& logRecord: m_evmcHost->recorded_logs)
		logs.emplace_back(
			EVMHost::convertFromEVMC(logRecord.creator),
			bytes{logRecord.data.begin(), logRecord.data.end()},
			logRecord.topics | ranges::views::transform([](evmc::bytes32 _bytes) { return EVMHost::convertFromEVMC(_bytes); }) | ranges::to<std::vector>
		);
	return logs;
}
