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

#include <libyul/backends/evm/ssa/io/Printer.h>

#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>
#include <libyul/backends/evm/ssa/SSACFG.h>

#include <libyul/Utilities.h>

#include <libsolutil/StringUtils.h>
#include <libsolutil/Visitor.h>

#include <fmt/format.h>
#include <fmt/ranges.h>

#include <range/v3/view/reverse.hpp>
#include <range/v3/view/transform.hpp>
#include <range/v3/view/zip.hpp>

#include <ostream>
#include <unordered_map>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::yul;
using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::io;

namespace
{

std::string formatValueRef(InstId const _id)
{
	return fmt::format("v{}", _id.value);
}

std::string formatBlockRef(BlockId const _id)
{
	return fmt::format("#{}", _id.value);
}

void printBuiltinOperands(
	std::ostream& _out,
	SSACFG const& _cfg,
	SSACFG::Inst const& _inst,
	InstId const _id
)
{
	auto const& payload = _cfg.builtinPayload(_id);
	auto const& builtin = _cfg.evmDialect.builtin(payload.builtin);

	_out << fmt::format("builtin @{}", builtin.name);

	if (builtin.numParameters == 0)
		return;

	_out << ' ';

	auto litIt = payload.literalArguments.begin();
	auto valIt = _inst.inputs.rbegin();
	for (std::size_t i = 0; i < builtin.numParameters; ++i)
	{
		if (i > 0)
			_out << ", ";
		if (builtin.literalArgument(i).has_value())
		{
			yulAssert(litIt != payload.literalArguments.end());
			_out << formatLiteral(*litIt++);
		}
		else
		{
			yulAssert(valIt != _inst.inputs.rend());
			_out << formatValueRef(*valIt++);
		}
	}
}

void printCallOperands(
	std::ostream& _out,
	ControlFlowGraphs const& _module,
	SSACFG::Inst const& _inst,
	InstId const _id,
	SSACFG const& _cfg
)
{
	auto const& payload = _cfg.callPayload(_id);
	SSACFG const* callee = _module.functionGraph(payload.graphID);
	yulAssert(callee);

	_out << fmt::format("call @{}", callee->name);

	if (_inst.inputs.empty())
		return;

	_out << ' ';
	bool first = true;
	for (auto it = _inst.inputs.rbegin(); it != _inst.inputs.rend(); ++it)
	{
		if (!first)
			_out << ", ";
		first = false;
		_out << formatValueRef(*it);
	}
}

void printInstruction(
	std::ostream& _out,
	ControlFlowGraphs const& _module,
	SSACFG const& _cfg,
	InstId _id,
	std::unordered_map<InstId::ValueType, std::size_t> const& _argIndex
)
{
	auto const& inst = _cfg.inst(_id);

	switch (inst.opcode)
	{
	case InstOpcode::Nop:
		_out << fmt::format("    {} = nop\n", formatValueRef(_id));
		return;
	case InstOpcode::Tombstone:
		_out << fmt::format("    {} = tombstone\n", formatValueRef(_id));
		return;
	case InstOpcode::Projection:
		yulAssert(inst.inputs.size() == 1);
		_out << fmt::format(
			"    {} = proj {}, {}\n",
			formatValueRef(_id),
			formatValueRef(inst.inputs.front()),
			_cfg.projectionIndex(_id)
		);
		return;
	case InstOpcode::Phi:
		_out << fmt::format("    {} = phi\n", formatValueRef(_id));
		return;
	case InstOpcode::Upsilon:
	{
		yulAssert(inst.inputs.size() == 1);
		_out << fmt::format(
			"    upsilon {} -> ^{}\n",
			formatValueRef(inst.inputs.front()),
			formatValueRef(_cfg.upsilonPhi(_id))
		);
		return;
	}
	case InstOpcode::Const:
		_out << fmt::format(
			"    {} = const {}\n",
			formatValueRef(_id),
			toCompactHexWithPrefix(_cfg.literalPayload(_id))
		);
		return;
	case InstOpcode::FunctionArg:
	{
		auto const it = _argIndex.find(_id.value);
		yulAssert(it != _argIndex.end(), "FunctionArg without an entry in SSACFG::arguments");
		_out << fmt::format("    {} = arg {}\n", formatValueRef(_id), it->second);
		return;
	}
	case InstOpcode::Unreachable:
		_out << fmt::format("    {} = unreachable\n", formatValueRef(_id));
		return;
	case InstOpcode::Identity:
		yulAssert(inst.inputs.size() == 1);
		_out << fmt::format(
			"    {} = identity {}\n",
			formatValueRef(_id),
			formatValueRef(inst.inputs.front())
		);
		return;
	case InstOpcode::MemoryGuard:
		_out << fmt::format("    {} = memoryguard\n", formatValueRef(_id));
		return;
	case InstOpcode::BuiltinCall:
	{
		_out << "    ";
		if (_cfg.numReturnsOf(_id) >= 1)
			_out << fmt::format("{} = ", formatValueRef(_id));
		printBuiltinOperands(_out, _cfg, inst, _id);
		_out << '\n';
		return;
	}
	case InstOpcode::Call:
	{
		auto const& payload = _cfg.callPayload(_id);
		_out << "    ";
		if (payload.numReturns >= 1)
			_out << fmt::format("{} = ", formatValueRef(_id));
		printCallOperands(_out, _module, inst, _id, _cfg);
		if (!payload.canContinue)
			_out << " { nocontinue = true }";
		_out << '\n';
		return;
	}
	}
	yulAssert(false, "unhandled InstOpcode in Printer");
}

void printExit(std::ostream& _out, SSACFG::BasicBlock const& _block)
{
	std::visit(GenericVisitor{
		[&](SSACFG::BasicBlock::MainExit const&)
		{
			_out << "    main_exit\n";
		},
		[&](SSACFG::BasicBlock::Jump const& _jump)
		{
			_out << fmt::format("    jump {}\n", formatBlockRef(_jump.target));
		},
		[&](SSACFG::BasicBlock::ConditionalJump const& _cjump)
		{
			_out << fmt::format(
				"    branch {}, {}, {}\n",
				formatValueRef(_cjump.condition),
				formatBlockRef(_cjump.nonZero),
				formatBlockRef(_cjump.zero)
			);
		},
		[&](SSACFG::BasicBlock::FunctionReturn const& _ret)
		{
			_out << "    return";
			bool first = true;
			for (InstId const v: _ret.returnValues)
			{
				_out << (first ? " " : ", ");
				first = false;
				_out << formatValueRef(v);
			}
			_out << '\n';
		},
		[&](SSACFG::BasicBlock::Terminated const&)
		{
			_out << "    terminated\n";
		}
	}, _block.exit);
}

void printBlock(
	std::ostream& _out,
	ControlFlowGraphs const& _module,
	SSACFG const& _cfg,
	BlockId const _id,
	std::unordered_map<InstId::ValueType, std::size_t> const& _argIndex
)
{
	auto const& block = _cfg.block(_id);

	if (_id != _cfg.entry && !block.entries.empty())
		_out << fmt::format(
			"{}: preds: {}\n",
			formatBlockRef(_id),
			fmt::join(block.entries | ranges::views::transform(formatBlockRef), ", ")
		);
	else
		_out << fmt::format("{}:\n", formatBlockRef(_id));

	for (InstId const id: block.instructions)
		printInstruction(_out, _module, _cfg, id, _argIndex);

	printExit(_out, block);
}

void printGraph(std::ostream& _out, ControlFlowGraphs const& _module, SSACFG const& _cfg)
{
	bool const wrapIntoFunc = !_cfg.isMainGraph();

	if (wrapIntoFunc)
	{
		_out << fmt::format(
			"func @{}(args: ({})) -> {}",
			_cfg.name,
			fmt::join(_cfg.arguments | ranges::views::transform(formatValueRef), ", "),
			_cfg.numReturns
		);
		if (!_cfg.canContinue)
			_out << " nocontinue";
		_out << " {\n";
	}

	std::unordered_map<InstId::ValueType, std::size_t> argIndex;
	for (std::size_t pos = 0; pos < _cfg.arguments.size(); ++pos)
		argIndex.emplace(_cfg.arguments[pos].value, pos);

	for (BlockId const id: _cfg.liveBlocks())
		printBlock(_out, _module, _cfg, id, argIndex);

	if (wrapIntoFunc)
		_out << "}\n";
}

}

void io::print(std::ostream& _out, ControlFlowGraphs const& _cfgs)
{
	if (_cfgs.memoryGuard)
		_out << fmt::format("memoryguard = {}\n\n", toCompactHexWithPrefix(*_cfgs.memoryGuard));

	for (auto const& graph: _cfgs.functionGraphs)
	{
		printGraph(_out, _cfgs, *graph);
		_out << '\n';
	}
}
