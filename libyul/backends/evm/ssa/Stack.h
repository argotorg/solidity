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

#pragma once

#include <libyul/backends/evm/ssa/ControlFlow.h>
#include <libyul/backends/evm/ssa/SSACFG.h>

#include <range/v3/algorithm/find.hpp>
#include <range/v3/view/reverse.hpp>

#include <cstdint>
#include <type_traits>

namespace solidity::yul
{

struct FunctionCall;

namespace ssa
{

/// Registry for tracking function call sites.
///
/// Maps FunctionCall AST nodes to unique numeric IDs. These IDs are used
/// to generate return labels for function calls in the EVM bytecode.
class CallSites
{
public:
	using CallSiteID = std::uint32_t;

	std::optional<CallSiteID> callSiteID(FunctionCall const* _functionCall) const
	{
		if (auto const it = ranges::find(m_data, _functionCall); it != m_data.end())
			return static_cast<CallSiteID>(std::distance(m_data.begin(), it));
		return std::nullopt;
	}

	FunctionCall const& functionCall(CallSiteID _callSite) const
	{
		yulAssert(_callSite < m_data.size());
		return *m_data[_callSite];
	}

	CallSiteID addCallSite(FunctionCall const* _functionCall)
	{
		if (auto const id = callSiteID(_functionCall))
			return *id;
		yulAssert(_functionCall);
		m_data.emplace_back(_functionCall);
		return static_cast<CallSiteID>(m_data.size() - 1);
	}
private:
	std::vector<FunctionCall const*> m_data;
};

/// A discriminated union corresponding to a single EVM stack slot.
/// Can represent:
///		- ValueID: SSA values (including literals)
///		- Junk: Placeholder/unused values
///     - FunctionCallReturnLabel: Return addresses for function calls
///     - FunctionReturnLabel: Identifies the calling function's graph
///
/// Memory layout is optimized: 8 bytes size for cache efficiency, trivially copyable, standard layout, trivial
class StackSlot
{
public:
	enum struct Kind: std::uint8_t
	{
		ValueID, // u32
		Junk, // empty
		FunctionCallReturnLabel, // index into corresponding stack layout's call sites
		FunctionReturnLabel // identifying the function graph via ControlFlow
	};

	constexpr StackSlot() = default;
	constexpr StackSlot(StackSlot const&) = default;
	constexpr StackSlot(StackSlot&&) = default;
	constexpr StackSlot& operator=(StackSlot const&) = default;
	constexpr StackSlot& operator=(StackSlot&&) = default;

	constexpr bool isValueID() const noexcept { return kind() == Kind::ValueID; }
	constexpr bool isLiteralValueID() const noexcept { return m_valueIdKind == SSACFG::ValueId::Kind::Literal; }
	constexpr bool isFunctionReturnLabel() const noexcept { return kind() == Kind::FunctionReturnLabel; }
	constexpr bool isFunctionCallReturnLabel() const noexcept { return kind() == Kind::FunctionCallReturnLabel; }
	constexpr bool isJunk() const noexcept { return kind() == Kind::Junk; }
	constexpr Kind kind() const noexcept { return m_kind; }

	ControlFlow::FunctionGraphID functionReturnLabel() const { yulAssert(isFunctionReturnLabel()); return m_payload; }
	CallSites::CallSiteID functionCallReturnLabel() const { yulAssert(isFunctionCallReturnLabel()); return m_payload; }
	SSACFG::ValueId valueID() const { yulAssert(isValueID()); return {m_payload, m_valueIdKind}; }

	static constexpr StackSlot makeJunk() { return {0, Kind::Junk}; }
	static constexpr StackSlot makeValueID(SSACFG::ValueId const& _valueID) { return {_valueID.value(), Kind::ValueID, _valueID.kind()}; }
	static constexpr StackSlot makeFunctionReturnLabel(ControlFlow::FunctionGraphID const _graphID) { return {_graphID, Kind::FunctionReturnLabel}; }
	static constexpr StackSlot makeFunctionCallReturnLabel(CallSites::CallSiteID const _callSiteID) { return {_callSiteID, Kind::FunctionCallReturnLabel};	}

	auto operator<=>(StackSlot const&) const = default;
private:
	constexpr StackSlot(std::uint32_t const _payload, Kind const _kind, SSACFG::ValueId::Kind const _valueIdKind = SSACFG::ValueId::Kind::Unreachable):
		m_payload(_payload),
		m_kind(_kind),
		m_valueIdKind(_valueIdKind)
	{}

	/// interpretation depends on kind
	std::uint32_t m_payload;
	Kind m_kind;
	SSACFG::ValueId::Kind m_valueIdKind;
};
static_assert(sizeof(StackSlot) == 8, "Want cache efficiency, benchmark this if you go beyond 8 bytes");
static_assert(std::is_trivially_copyable_v<StackSlot>, "Should be able to use memcpy semantics");
static_assert(std::is_standard_layout_v<StackSlot>, "Want to have a predictable layout");
static_assert(std::is_trivial_v<StackSlot>, "Want to have no init/cpy overhead");

using StackData = std::vector<StackSlot>;
std::string slotToString(StackSlot const& _slot);
std::string slotToString(StackSlot const& _slot, SSACFG const& _cfg);
std::string stackToString(StackData const& _stackData, SSACFG const& _cfg);
std::string stackToString(StackData const& _stackData);

template<typename StackManipulationCallback>
concept StackManipulationCallbackConcept = requires(
	StackManipulationCallback& _callback,
	StackSlot _slot,
	size_t _depth
)
{
	{ _callback.swap(_depth) } -> std::same_as<void>;
	{ _callback.dup(_depth) } -> std::same_as<void>;
	{ _callback.push(_slot) } -> std::same_as<void>;
	{ _callback.pop() } -> std::same_as<void>;
};

struct NoOpStackManipulationCallbacks
{
	static void swap(size_t) {}
	static void dup(size_t) {}
	static void push(StackSlot const&) {}
	static void pop() {}
};
static_assert(StackManipulationCallbackConcept<NoOpStackManipulationCallbacks>);

template<
	StackManipulationCallbackConcept CallbacksType = NoOpStackManipulationCallbacks
>
class Stack
{
	static size_t constexpr reachableStackDepth = 16;
public:
	using Callbacks = CallbacksType;

	using Slot = StackSlot;
	using Data = StackData;

	/// Array index into stack from the bottom (offset 0 = bottom).
	/// Natural for array-like access and iteration; used when treating the stack as a data structure.
	struct Offset
	{
		explicit constexpr Offset(size_t _value) : value(_value) {}
		size_t value;
		auto operator<=>(Offset const&) const = default;
	};
	// comparison operations with size_t
	friend constexpr auto operator<=>(Offset lhs, size_t rhs) noexcept { return lhs.value <=> rhs; }
	friend constexpr auto operator<=>(size_t lhs, Offset rhs) noexcept { return lhs <=> rhs.value; }

	/// Distance from the stack top (depth 0 = top).
	/// Natural for stack operations (SWAP1 = swap with depth 1); used for operations that
	/// conceptually work "from the top".
	struct Depth
	{
		explicit constexpr Depth(size_t _value) : value(_value) {}
		size_t value;
		auto operator<=>(Depth const&) const = default;
	};
	// comparison operations with size_t
	friend constexpr auto operator<=>(Depth lhs, size_t rhs) noexcept { return lhs.value <=> rhs; }
	friend constexpr auto operator<=>(size_t lhs, Depth rhs) noexcept { return lhs <=> rhs.value; }

	Stack(
		Data& _data,
		Callbacks _callbacks
	):
		m_data(&_data),
		m_callbacks(std::move(_callbacks))
	{}

	Slot const& top() const
	{
		yulAssert(!m_data->empty());
		return m_data->back();
	}

	void swap(Depth const& _depth) { swap(depthToOffset(_depth)); }
	void swap(Offset const& _offset)
	{
		yulAssert(swapReachable(_offset), "Stack too deep");
		std::swap((*m_data)[_offset.value], m_data->back());
		if constexpr (!std::is_same_v<Callbacks, NoOpStackManipulationCallbacks>)
			m_callbacks.swap(offsetToDepth(_offset).value);
	}

	/// if the stack state needs to be updated without notifying the callback, the template parameter can be set to false
	template<bool callback=true>
	void pop()
	{
		yulAssert(!m_data->empty());
		m_data->pop_back();
		if constexpr (callback && !std::is_same_v<Callbacks, NoOpStackManipulationCallbacks>)
			m_callbacks.pop();
	}

	/// if the stack state needs to be updated without notifying the callback, the template parameter can be set to false
	template<bool callback=true>
	void push(Slot const& _slot)
	{
		m_data->emplace_back(_slot);
		if constexpr (callback && !std::is_same_v<Callbacks, NoOpStackManipulationCallbacks>)
			m_callbacks.push(_slot);
	}

	void dup(Depth const& _depth) { dup(depthToOffset(_depth)); }
	void dup(Offset const& _offset)
	{
		yulAssert(dupReachable(_offset), "Stack too deep");
		m_data->push_back((*m_data)[_offset.value]);
		if constexpr (!std::is_same_v<Callbacks, NoOpStackManipulationCallbacks>)
			m_callbacks.dup(offsetToDepth(_offset).value + 1);
	}

	bool dupReachable(Offset const& _offset) const noexcept { return dupReachable(offsetToDepth(_offset)); }
	bool dupReachable(Depth const& _depth) const noexcept { return _depth < size() && _depth.value + 1 <= reachableStackDepth; }
	bool swapReachable(Offset const& _offset) const noexcept { return swapReachable(offsetToDepth(_offset)); }
	bool swapReachable(Depth const& _depth) const noexcept { return _depth < size() && 1 <= _depth.value && _depth.value <= reachableStackDepth; }

	void declareJunk(Depth const& _depth) { (*m_data)[depthToOffset(_depth).value] = Slot::makeJunk(); }

	Slot const& slot(Depth const& _depth) const { return (*m_data)[depthToOffset(_depth).value]; }
	Slot const& slot(Offset const& _offset) const { return slot(offsetToDepth(_offset)); }
	bool empty() const noexcept { return size() == 0; }
	size_t size() const noexcept { return m_data->size(); }

	std::optional<Depth> findSlotDepth(Slot const& _value) const
	{
		auto rview = *this | ranges::views::reverse;
		auto it = ranges::find(rview, _value);

		if (it == ranges::end(rview))
			return std::nullopt;

		return Depth{static_cast<size_t>(std::distance(ranges::begin(rview), it))};
	}

	static bool constexpr canBeFreelyGenerated(Slot const& _slot)
	{
		return _slot.isLiteralValueID() || _slot.isJunk() || _slot.isFunctionCallReturnLabel();
	}

	Slot const& operator[](Offset const& _index) const noexcept { return (*m_data)[_index.value]; }
	auto begin() const { return ranges::begin(*m_data); }
	auto end() const { return ranges::end(*m_data); }

	Data const& data() const
	{
		return *m_data;
	}

	Callbacks const& callbacks() const { return m_callbacks; }

	/// index scheme conversion offset -> depth
	Depth offsetToDepth(Offset const& _offset) const
	{
		yulAssert(_offset < size(), "Offset out of range");
		return Depth{size() - _offset.value - 1};
	}
	/// index scheme conversion depth -> offset
	Offset depthToOffset(Depth const& _depth) const
	{
		yulAssert(_depth < size(), "Depth out of range");
		return Offset{size() - _depth.value - 1};
	}

private:
	Data* m_data;
	Callbacks m_callbacks;
};

}
}
