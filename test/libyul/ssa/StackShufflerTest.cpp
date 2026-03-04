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

#include <test/libyul/ssa/StackShufflerTest.h>

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/StackShuffler.h>

#include <range/v3/view/split.hpp>

#include <fmt/ranges.h>

#include <algorithm>
#include <cstddef>
#include <functional>
#include <optional>
#include <ostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;
using namespace solidity::yul::test;
using namespace solidity::yul::test::ssa;

namespace
{
std::string_view constexpr parserKeyInitialStack {"initial"};
std::string_view constexpr parserKeyStackTop {"targetStackTop"};
std::string_view constexpr parserKeyTailSet {"targetStackTailSet"};
std::string_view constexpr parserKeyStackSize {"targetStackSize"};

using Liveness = LivenessAnalysis::LivenessData;
using Slot = StackSlot;
using ValueId = SSACFG::ValueId;
struct StackManipulationCallbacks
{
	void swap(size_t _depth) const
	{
		if (hook)
			(*hook)(fmt::format("SWAP{}", _depth));
	}
	void dup(size_t const _depth) const
	{
		if (hook)
			(*hook)(fmt::format("DUP{}", _depth));
	}
	void push(Slot const& _slot) const
	{
		if (hook)
			(*hook)(fmt::format("PUSH {}", slotToString(_slot)));
	}
	void pop() const
	{
		if (hook)
			(*hook)("POP");
	}

	std::optional<std::function<void(std::string const&)>> hook = std::nullopt;
};
using TestStack = Stack<StackManipulationCallbacks>;

/// removes leading and trailing whitespace from a string view
std::string_view trim(std::string_view s)
{
	s.remove_prefix(std::min(s.find_first_not_of(" \t\r\v\n"), s.size()));
	s.remove_suffix(std::min(s.size() - s.find_last_not_of(" \t\r\v\n") - 1, s.size()));
	return s;
}

/// Parse a value ID token like "v172", "phi109", "lit7", or "JUNK".
Slot parseSlot(std::string_view token)
{
	if (token == "JUNK")
		return Slot::makeJunk();

	if (token.starts_with("v"))
	{
		if (auto const num = util::parseArithmetic<ValueId::ValueType>(token.substr(1)))
			return Slot::makeValueID(ValueId::makeVariable(*num));
		throw std::runtime_error(fmt::format("Couldn't parse variable token: {}", token));
	}

	if (token.starts_with("phi"))
	{
		if (auto const num = util::parseArithmetic<ValueId::ValueType>(token.substr(3)))
			return Slot::makeValueID(ValueId::makePhi(*num));
		throw std::runtime_error(fmt::format("Couldn't parse phi token: {}", token));
	}

	if (token.starts_with("lit"))
	{
		if (auto const num = util::parseArithmetic<ValueId::ValueType>(token.substr(3)))
			return Slot::makeValueID(ValueId::makeLiteral(*num));
		throw std::runtime_error(fmt::format("Couldn't parse literal token: {}", token));
	}
	throw std::runtime_error(fmt::format("Unknown token: {}", token));
}

/// Parse a string like "[v172, phi109, lit7, JUNK]" into Stack::Data
TestStack::Data parseSlots(std::string_view _input, char const brackBegin = '[', char const brackEnd = ']')
{
	TestStack::Data result;

	// trim and remove brackets
	{
		_input = trim(_input);
		yulAssert(_input.starts_with(brackBegin));
		_input.remove_prefix(1);
		yulAssert(_input.ends_with(brackEnd));
		_input.remove_suffix(1);
	}

	for (auto&& slotToken: ranges::views::split(_input, ','))
	{
		auto const slotTokenBegin = ranges::begin(slotToken);
		auto const slotTokenEnd  = ranges::end(slotToken);

		std::string_view token;
		if(slotTokenBegin != slotTokenEnd)
			token = {&*slotTokenBegin, static_cast<std::size_t>(ranges::distance(slotTokenBegin, slotTokenEnd))};
		token = trim(token);
		yulAssert(!token.empty(), "Empty token.");
		result.push_back(parseSlot(token));
	}
	return result;
}

/// Parse liveness like "{phi109, phi150, v172}"
/// Returns Liveness with reference count 1 for each value
Liveness parseLiveness(std::string_view _input)
{
	auto const slots = parseSlots(_input, '{', '}');
	std::vector<std::pair<ValueId, uint32_t>> liveCounts;
	liveCounts.reserve(slots.size());
	for (auto const& slot: slots)
	{
		yulAssert(slot.isValueID(), "Only value IDs are permitted in liveness definition.");
		liveCounts.emplace_back(slot.valueID(), 1);
	}
	return {liveCounts.begin(), liveCounts.end()};
}

struct ShuffleTestInput
{
	std::optional<TestStack::Data> initial;
	std::optional<TestStack::Data> targetStackTop;
	std::optional<Liveness> targetStackTailSet;
	std::optional<size_t> targetStackSize;

	bool valid() const
	{
		return initial.has_value() &&
			targetStackTop.has_value() &&
			targetStackTailSet.has_value() &&
			targetStackSize.has_value();
	}

	static ShuffleTestInput parse(std::string_view _source)
	{
		ShuffleTestInput result;

		auto const stripComment = [](std::string_view sv) -> std::string_view
		{
			auto const pos = sv.find("//");
			if (pos != std::string_view::npos)
				return sv.substr(0, pos);
			return sv;
		};

		for (auto&& lineRange: ranges::views::split(_source, '\n'))
		{
			auto lineBegin = ranges::begin(lineRange);
			auto lineEnd  = ranges::end(lineRange);
			if (lineBegin == lineEnd)
				continue;

			std::string_view line{&*lineBegin, static_cast<std::size_t>(ranges::distance(lineBegin, lineEnd))};
			line = trim(stripComment(line));
			if (line.empty())
				continue;

			auto const colonPos = line.find(':');
			if (colonPos == std::string_view::npos)
				continue;

			auto const key = trim(line.substr(0, colonPos));
			auto const value = trim(line.substr(colonPos + 1));

			if (key == parserKeyInitialStack)
				result.initial = parseSlots(value, '[', ']');
			else if (key == parserKeyStackTop)
				result.targetStackTop = parseSlots(value, '[', ']');
			else if (key == parserKeyTailSet)
				result.targetStackTailSet = parseLiveness(value);
			else if (key == parserKeyStackSize)
			{
				if (auto num = util::parseArithmetic<std::size_t>(value))
					result.targetStackSize = *num;
				else
					throw std::runtime_error(fmt::format("Couldn't parse targetStackSize: {}", value));
			}

		}
		return result;
	}
};

/// Records a shuffling trace and produces formatted output into some ostream when going out of scope
class TraceRecorder
{
	static size_t constexpr operationColumnWidth = 12;
	static size_t constexpr slotColumnWidth = 7;
	static char constexpr junkSymbol = '*';

public:
	TraceRecorder(std::ostream& _out, TestStack::Data const& _targetArgs, Liveness const& _targetTail, size_t _targetStackSize):
		m_out(_out),
		m_targetArgs(_targetArgs),
		m_targetTail(_targetTail),
		m_targetStackSize(_targetStackSize),
		m_targetTailSize(
			[&] {
				yulAssert(_targetStackSize >= m_targetArgs.size());
				return _targetStackSize - m_targetArgs.size();
			}()
		)
	{}

	void record(std::string const& _operation, TestStack::Data const& _stack)
	{
		m_entries.push_back(TraceEntry{_operation, _stack});
	}

	~TraceRecorder()
	{
		if (m_entries.empty())
			return;

		size_t maxStackDepth = 0;
		for (const auto& [operation, stackAfter]: m_entries)
			maxStackDepth = std::max(maxStackDepth, stackAfter.size());

		if (maxStackDepth == 0)
			return;

		bool const hasExcess = maxStackDepth > m_targetStackSize;

		emitHeader(maxStackDepth, hasExcess);
		emitSeparatorLine(maxStackDepth, hasExcess);
		for (auto const& entry: m_entries)
			emitDataRow(entry, hasExcess);
		emitSeparatorLine(maxStackDepth, hasExcess);
		emitTargetRow(hasExcess);
	}

private:
	struct TraceEntry {
		std::string operation;
		TestStack::Data stackAfter;
	};

	std::ostream& m_out;
	std::vector<TraceEntry> m_entries;
	TestStack::Data const& m_targetArgs;
	Liveness const& m_targetTail;
	size_t const m_targetStackSize;
	size_t const m_targetTailSize;

	void emitSeparator(size_t const _index, bool const _hasExcess, char const _junction) const
	{
		bool const endOfTargetTail = _index == m_targetTailSize && !m_targetArgs.empty() && m_targetTailSize > 0;
		bool const endOfTargetStackWithExcess = _hasExcess && _index == m_targetTailSize + m_targetArgs.size();
		if (endOfTargetTail || endOfTargetStackWithExcess)
			m_out << ' ' << _junction;
	}

	void emitHeader(size_t const _maxStackDepth, bool const _hasExcess) const
	{
		m_out << fmt::format("{:>{}}", "", operationColumnWidth) << "|";
		for (size_t i = 0; i < _maxStackDepth; ++i)
		{
			emitSeparator(i, _hasExcess, '|');
			m_out << fmt::format("{:>{}}", i, slotColumnWidth);
		}
		m_out << "\n";
	}

	void emitSeparatorLine(size_t const _maxStackDepth, bool const _hasExcess) const
	{
		m_out << fmt::format("{:>{}}", "", operationColumnWidth) << '+';
		for (size_t i = 0; i < _maxStackDepth; ++i)
		{
			emitSeparator(i, _hasExcess, '+');
			m_out << std::string(slotColumnWidth, '-');
		}
		m_out << '\n';
	}

	void emitDataRow(TraceEntry const& _entry, bool const _hasExcess) const
	{
		m_out << fmt::format("{:>{}}", _entry.operation, operationColumnWidth) << "|";
		for (size_t i = 0; i < _entry.stackAfter.size(); ++i)
		{
			emitSeparator(i, _hasExcess, '|');
			auto const& slot = _entry.stackAfter[i];
			std::string slotStr = slot.isJunk() ? std::string(1, junkSymbol) : slotToString(slot);
			m_out << fmt::format("{:>{}}", slotStr, slotColumnWidth);
		}
		m_out << '\n';
	}

	void emitTargetRow(bool const _hasExcess) const
	{
		m_out << fmt::format("{:>{}}", "(target)", operationColumnWidth) << "|";

		// Print tail region with set notation
		if (m_targetTailSize > 0 && !(m_targetTail.empty() && m_targetArgs.empty()))
		{
			std::string const tailSetStr = fmt::format(
				"{{{}}}",
				fmt::join(
					m_targetTail | ranges::views::keys | ranges::views::transform(
						[](auto const& id) { return slotToString(Slot::makeValueID(id)); }
					),
					", "
				)
			);
			m_out << fmt::format("{:>{}}", tailSetStr, m_targetTailSize * slotColumnWidth);
		}

		// Args separator
		if (!m_targetArgs.empty() && m_targetTailSize > 0)
			m_out << " |";

		// Print args region
		for (auto const& slot: m_targetArgs)
		{
			std::string slotStr = slot.isJunk() ? std::string(1, junkSymbol) : slotToString(slot);
			m_out << fmt::format("{:>{}}", slotStr, slotColumnWidth);
		}

		// Excess separator
		if (_hasExcess)
			m_out << " |";

		m_out << '\n';
	}
};
}

std::unique_ptr<frontend::test::TestCase> ShufflingTest::create(Config const& _config)
{
	return std::make_unique<ShufflingTest>(_config.filename);
}

ShufflingTest::ShufflingTest(std::string const& _filename): TestCase(_filename)
{
	m_source = m_reader.source();
	auto dialectName = m_reader.stringSetting("dialect", "evm");
	soltestAssert(dialectName == "evm");
	m_expectation = m_reader.simpleExpectations();
}

ShufflingTest::TestResult ShufflingTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
{
	auto const testConfig = ShuffleTestInput::parse(m_source);
	if (!testConfig.valid())
	{
		  static constexpr std::string_view formatHelp = R"(initial: [<slot>, ...]
targetStackTop: [<slot>, ...]
targetStackTailSet: {<slot>, ...}
targetStackSize: <non-negative integer>

Where <slot> is one of:
  v<N>    - variable
  phi<N>  - phi node
  lit<N>  - literal
  JUNK    - junk slot

Lines starting with // are comments. Comments at the end of lines are supported, too.)";
		util::AnsiColorized out(_stream, _formatted, {util::formatting::BOLD, util::formatting::RED});
		out	<< _linePrefix << fmt::format("Error parsing source. Expected format:") << '\n';

		for (auto const line: ranges::views::split(formatHelp, '\n'))
		{
			auto const lineSVBegin = ranges::begin(line);
			auto const lineSVEnd = ranges::end(line);
			std::string_view lineSV;
			if (lineSVBegin != lineSVEnd)
				lineSV = {&*lineSVBegin, static_cast<std::size_t>(ranges::distance(lineSVBegin, lineSVEnd))};
			out << _linePrefix << "  " << lineSV << '\n';
		}
		return TestResult::FatalError;
	}

	auto stackData = *testConfig.initial;
	std::ostringstream oss;
	{
		TraceRecorder trace(oss, *testConfig.targetStackTop, *testConfig.targetStackTailSet, *testConfig.targetStackSize);
		trace.record("(initial)", *testConfig.initial);
		TestStack stack(stackData, {.hook = [&](std::string const& op){ trace.record(op, stackData); }});
		StackShuffler<StackManipulationCallbacks>::shuffle(
			stack,
			*testConfig.targetStackTop,
			*testConfig.targetStackTailSet,
			*testConfig.targetStackSize
		);
	}
	// check stack data
	{
		yulAssert(*testConfig.targetStackSize >= testConfig.targetStackTop->size());
		auto const tailSize = *testConfig.targetStackSize - testConfig.targetStackTop->size();
		yulAssert(stackData.size() == *testConfig.targetStackSize);
		for (const auto& valueID: *testConfig.targetStackTailSet | ranges::views::keys)
		{
			auto const findIt = ranges::find(
				stackData.begin(),
				stackData.begin() + static_cast<std::ptrdiff_t>(tailSize),
				StackSlot::makeValueID(valueID)
			);
			yulAssert(findIt != ranges::end(stackData));
		}
		for (std::size_t offset = tailSize; offset < *testConfig.targetStackSize; ++offset)
		{
			auto const& targetSlot = testConfig.targetStackTop->at(offset - tailSize);
			yulAssert(targetSlot.isJunk() || stackData[offset] == targetSlot);
		}
	}
	m_obtainedResult = oss.str();


	return checkResult(_stream, _linePrefix, _formatted);
}
