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
#include <libyul/optimiser/SwitchSplitter.h>

#include <libyul/optimiser/ASTCopier.h>
#include <libyul/optimiser/Metrics.h>
#include <libyul/optimiser/OptimiserStep.h>
#include <libyul/AST.h>
#include <libyul/Dialect.h>
#include <libyul/backends/evm/EVMDialect.h>

#include <libevmasm/GasMeter.h>
#include <libsolutil/CommonData.h>
#include <libsolutil/Numeric.h>

#include <algorithm>
#include <optional>
#include <span>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::yul;

using OptionalStatements = std::optional<std::vector<Statement>>;

void SwitchSplitter::run(OptimiserStepContext& _context, Block& _ast)
{
	SwitchSplitter{_context}(_ast);
}

SwitchSplitter::SwitchSplitter(OptimiserStepContext const& _context):
	m_runs(_context.expectedExecutionsPerDeployment.value_or(0))
{
	if (auto const* evmDialect = dynamic_cast<EVMDialect const*>(&_context.dialect))
		m_gtHandle = evmDialect->findBuiltin("gt");
}

void SwitchSplitter::operator()(Block& _block)
{
	simplify(_block.statements);
}

void SwitchSplitter::simplify(std::vector<Statement>& _statements)
{
	iterateReplacing(
		_statements,
		[&](Statement& _stmt) -> OptionalStatements
		{
			if (auto* sw = std::get_if<Switch>(&_stmt))
				if (auto result = tryTransform(*sw))
				{
					simplify(*result);
					return result;
				}
			this->visit(_stmt);
			return {};
		}
	);
}

std::optional<std::vector<Statement>> SwitchSplitter::tryTransform(Switch& _switch)
{
	if (!m_gtHandle)
		return {};

	// Only switches on a simple identifier are transformed; without ExpressionSplitter
	// having run first, more complex expressions are left untouched here.
	auto const* exprIdent = std::get_if<Identifier>(_switch.expression.get());
	if (!exprIdent)
		return {};

	// Separate literal cases from the default case.
	std::vector<Case const*> literalCases;
	Block const* defaultBody = nullptr;
	static Block const emptyBlock{};

	for (auto const& c: _switch.cases)
		if (c.value)
			literalCases.push_back(&c);
		else
			defaultBody = &c.body;

	if (!defaultBody)
		defaultBody = &emptyBlock;

	std::sort(literalCases.begin(), literalCases.end(), [](Case const* _a, Case const* _b) {
		return _a->value->value.value() < _b->value->value.value();
	});

	// Only transform if the top-level split is profitable.
	if (!shouldSplit(literalCases, *defaultBody))
		return {};

	return buildTree(literalCases, *exprIdent, *defaultBody, _switch.debugData);
}

std::vector<Statement> SwitchSplitter::buildTree(
	std::span<Case const* const> _cases,
	Identifier const& _expr,
	Block const& _defaultBody,
	langutil::DebugData::ConstPtr _debugData
)
{
	size_t n = _cases.size();
	bool const hasDefault = !_defaultBody.statements.empty();

	if (!shouldSplit(_cases, _defaultBody))
	{
		// Leaf: small switch; default case added only when present.
		std::vector<Case> switchCases;
		switchCases.reserve(n + (hasDefault ? 1 : 0));
		for (auto const* c: _cases)
			switchCases.push_back(Case{
				c->debugData,
				std::make_unique<Literal>(*c->value),
				ASTCopier{}.translate(c->body)
			});
		if (hasDefault)
			switchCases.push_back(Case{_debugData, nullptr, ASTCopier{}.translate(_defaultBody)});
		std::vector<Statement> result;
		result.emplace_back(Switch{_debugData, std::make_unique<Expression>(_expr), std::move(switchCases)});
		return result;
	}

	// Split: pivot stays in lower half → switch gt(expr, pivot) case 1 { upper } default { lower }.
	size_t pivotIdx = (n - 1) / 2;
	Case const* pivot = _cases[pivotIdx];

	auto lowerStmts = buildTree(_cases.subspan(0, pivotIdx + 1), _expr, _defaultBody, _debugData);
	auto upperStmts = buildTree(_cases.subspan(pivotIdx + 1), _expr, _defaultBody, _debugData);

	std::vector<Case> switchCases;
	switchCases.reserve(2);
	switchCases.push_back(Case{
		_debugData,
		std::make_unique<Literal>(Literal{_debugData, LiteralKind::Number, LiteralValue{u256(1)}}),
		Block{_debugData, std::move(upperStmts)}
	});
	switchCases.push_back(Case{_debugData, nullptr, Block{_debugData, std::move(lowerStmts)}});

	std::vector<Statement> result;
	result.emplace_back(Switch{
		_debugData,
		std::make_unique<Expression>(FunctionCall{
			_debugData,
			BuiltinName{_debugData, *m_gtHandle},
			{Expression{_expr}, Expression{*pivot->value}}
		}),
		std::move(switchCases)
	});
	return result;
}

bool SwitchSplitter::shouldSplit(std::span<Case const* const> _cases, Block const& _defaultBody) const
{
	size_t const n = _cases.size();
	if (n <= 4)
		return false;

	// Overhead scales with the fulcrum's actual encoding size.
	size_t const pivotIdx = (n - 1) / 2;
	unsigned const fulcrumSize = numberEncodingSize(_cases[pivotIdx]->value->value.value());
	size_t const overhead = 13 + fulcrumSize + CodeSize::codeSize(_defaultBody);
	return m_runs * 6 * (n - 4) > overhead * evmasm::GasCosts::createDataGas;
}
