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

#include <libyul/backends/evm/ssa/io/JSONExporter.h>

#include <libyul/Utilities.h>

#include <libsolutil/Algorithms.h>
#include <libsolutil/Numeric.h>
#include <libsolutil/Visitor.h>

#include <range/v3/algorithm/any_of.hpp>
#include <range/v3/view/drop.hpp>
#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/transform.hpp>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::io::json;

namespace
{
Json toJson(SSACFG const& _cfg, ranges::input_range auto&& _values) requires std::convertible_to<ranges::range_reference_t<decltype(_values)>, InstId>
{
	Json ret = Json::array();
	for (InstId const value: _values)
		ret.push_back(value.str(_cfg));
	return ret;
}

Json toJson(Json& _ret, SSACFG const& _cfg, InstId const _instId, ControlFlowGraphs const& _controlFlow)
{
	auto const& inst = _cfg.inst(_instId);
	Json opJson = Json::object();
	switch (inst.opcode)
	{
	case InstOpcode::Call:
	{
		auto const& callPayload = _cfg.callPayload(_instId);
		_ret["type"] = "FunctionCall";
		opJson["op"] = _controlFlow.functionGraph(callPayload.graphID)->name;
		break;
	}
	case InstOpcode::BuiltinCall:
	{
		auto const& builtinPayload = _cfg.builtinPayload(_instId);
		_ret["type"] = "BuiltinCall";
		Json builtinArgsJson = Json::array();
		for (auto const& literal: builtinPayload.literalArguments)
			builtinArgsJson.push_back(formatLiteral(literal));

		if (!builtinArgsJson.empty())
			opJson["literalArgs"] = builtinArgsJson;

		opJson["op"] = _cfg.evmDialect.builtin(builtinPayload.builtin).name;
		break;
	}
	case InstOpcode::MemoryGuard:
		_ret["type"] = "MemoryGuard";
		opJson["op"] = "memoryguard";
		break;
	default:
		yulAssert(false);
	}

	opJson["in"] = toJson(_cfg, inst.inputs);
	opJson["out"] = toJson(_cfg, _cfg.outputsOf(_instId));

	return opJson;
}

Json toJson(SSACFG const& _cfg, SSACFG::BlockId _blockId, LivenessAnalysis const* _liveness, ControlFlowGraphs const& _controlFlow)
{
	auto const valueToString = [&](auto const& _live) { return _live.first.str(_cfg); };

	Json blockJson = Json::object();
	auto const& block = _cfg.block(_blockId);

	blockJson["id"] = "Block" + std::to_string(_blockId.value);
	if (_liveness)
	{
		Json livenessJson = Json::object();
		livenessJson["in"] = _liveness->liveIn(_blockId)
			| ranges::views::transform(valueToString)
			| ranges::to<Json::array_t>();
		livenessJson["out"] = _liveness->liveOut(_blockId)
			| ranges::views::transform(valueToString)
			| ranges::to<Json::array_t>();
		blockJson["liveness"] = livenessJson;
	}
	blockJson["instructions"] = Json::array();
	bool const hasPhis = ranges::any_of(block.instructions, [&](InstId id) {
		return _cfg.isPhi(id);
	});
	if (hasPhis)
		blockJson["entries"] = block.entries
			| ranges::views::transform([](auto const& entry) { return "Block" + std::to_string(entry.value); })
			| ranges::to<Json::array_t>();
	_cfg.forEachPhi(block, [&](InstId const instId, SSACFG::Inst const&) {
		// Reconstruct phi arguments from upsilon Insts in predecessor blocks.
		std::vector<InstId> phiArgs;
		for (auto const& entryId: block.entries)
			for (InstId const predInstId: _cfg.block(entryId).instructions)
			{
				auto const& predInst = _cfg.inst(predInstId);
				if (!predInst.isUpsilon())
					continue;
				if (_cfg.upsilonPhi(predInstId) == instId)
				{
					phiArgs.push_back(predInst.inputs.at(0));
					break;
				}
			}
		Json phiJson = Json::object();
		phiJson["op"] = "PhiFunction";
		phiJson["in"] = toJson(_cfg, phiArgs);
		phiJson["out"] = toJson(_cfg, std::vector{instId});
		blockJson["instructions"].push_back(phiJson);
	});
	_cfg.forEachOperation(block, [&](InstId const instId, SSACFG::Inst const&) {
		blockJson["instructions"].push_back(toJson(blockJson, _cfg, instId, _controlFlow));
	});

	return blockJson;
}

Json exportBlock(SSACFG const& _cfg, SSACFG::BlockId _entryId, LivenessAnalysis const* _liveness, ControlFlowGraphs const& _controlFlow)
{
	Json blocksJson = Json::array();
	solidity::util::BreadthFirstSearch<SSACFG::BlockId> bfs{{{_entryId}}};
	bfs.run([&](SSACFG::BlockId _blockId, auto _addChild) {
		Json blockJson = toJson(_cfg, _blockId, _liveness, _controlFlow);

		Json exitBlockJson = Json::object();
		std::visit(solidity::util::GenericVisitor{
			[&](SSACFG::BasicBlock::MainExit const&) {
				exitBlockJson["type"] = "MainExit";
			},
			[&](SSACFG::BasicBlock::Jump const& _jump){
				exitBlockJson["targets"] = { "Block" + std::to_string(_jump.target.value) };
				exitBlockJson["type"] = "Jump";
				_addChild(_jump.target);
			},
			[&](SSACFG::BasicBlock::ConditionalJump const& _conditionalJump) {
				exitBlockJson["targets"] = { "Block" + std::to_string(_conditionalJump.zero.value), "Block" + std::to_string(_conditionalJump.nonZero.value) };
				exitBlockJson["cond"] = _conditionalJump.condition.str(_cfg);
				exitBlockJson["type"] = "ConditionalJump";

				_addChild(_conditionalJump.zero);
				_addChild(_conditionalJump.nonZero);
			},
			[&](SSACFG::BasicBlock::FunctionReturn const& _return) {
				exitBlockJson["returnValues"] = toJson(_cfg, _return.returnValues);
				exitBlockJson["type"] = "FunctionReturn";
			},
			[&](SSACFG::BasicBlock::Terminated const&) {
				exitBlockJson["type"] = "Terminated";
			}
		}, _cfg.block(_blockId).exit);
		blockJson["exit"] = exitBlockJson;
		blocksJson.emplace_back(blockJson);
	});

	return blocksJson;
}

Json exportFunction(SSACFG const& _cfg, LivenessAnalysis const* _liveness, ControlFlowGraphs const& _controlFlow)
{
	Json functionJson = Json::object();
	functionJson["type"] = "Function";
	functionJson["entry"] = "Block" + std::to_string(_cfg.entry.value);
	static auto constexpr argsTransform = [](InstId const& _arg) { return fmt::format("v{}", _arg.value); };
	functionJson["arguments"] = _cfg.arguments | ranges::views::transform(argsTransform) | ranges::to<std::vector>;
	functionJson["numReturns"] = _cfg.numReturns;
	functionJson["blocks"] = exportBlock(_cfg, _cfg.entry, _liveness, _controlFlow);
	return functionJson;
}

}

Json io::json::exportControlFlow(ControlFlowGraphs const& _controlFlow, ControlFlowGraphsLiveness const* _liveness)
{
	if (_liveness)
		yulAssert(&_liveness->controlFlowGraphs.get() == &_controlFlow);

	Json yulObjectJson = Json::object();
	if (_controlFlow.memoryGuard)
		yulObjectJson["memoryGuard"] = toCompactHexWithPrefix(*_controlFlow.memoryGuard);
	yulObjectJson["blocks"] = exportBlock(
		*_controlFlow.mainGraph(),
		SSACFG::BlockId{0},
		_liveness ? _liveness->cfgLiveness.front().get() : nullptr,
		_controlFlow
	);

	Json functionsJson = Json::object();
	for (std::size_t index = 1; index < _controlFlow.functionGraphs.size(); ++index)
	{
		SSACFG const& functionGraph = *_controlFlow.functionGraphs[index];
		functionsJson[functionGraph.name] = exportFunction(
			functionGraph,
			_liveness ? _liveness->cfgLiveness[index].get() : nullptr,
			_controlFlow
		);
	}
	yulObjectJson["functions"] = functionsJson;

	return yulObjectJson;
}
