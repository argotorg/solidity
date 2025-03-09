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

#include <test/libsolidity/MemoryGuardTest.h>

#include <test/Common.h>
#include <test/libyul/Common.h>

#include <libsolidity/codegen/ir/Common.h>

#include <libsolutil/Algorithms.h>
#include <libsolutil/StringUtils.h>

#include <libyul/Object.h>
#include <libyul/optimiser/FunctionCallFinder.h>
#include <libyul/AST.h>
#include <libyul/YulStack.h>

#include <fstream>
#include <memory>
#include <stdexcept>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::util::formatting;
using namespace solidity::langutil;
using namespace solidity::frontend;
using namespace solidity::frontend::test;
using namespace solidity::test;
using namespace solidity::yul::test;
using namespace yul;

void MemoryGuardTest::setupCompiler(CompilerStack& _compiler)
{
	AnalysisFramework::setupCompiler(_compiler);

	_compiler.setViaIR(true);
	_compiler.setOptimiserSettings(OptimiserSettings::none());
}

TestCase::TestResult MemoryGuardTest::run(std::ostream& _stream, std::string const& _linePrefix, bool _formatted)
{
	if (!runFramework(m_source, PipelineStage::Compilation))
	{
		printPrefixed(_stream, formatErrors(filteredErrors(), _formatted), _linePrefix);
		return TestResult::FatalError;
	}

	m_obtainedResult.clear();
	for (std::string contractName: compiler().contractNames())
	{
		ErrorList errors;
		std::optional<std::string> const& ir = compiler().yulIR(contractName);
		soltestAssert(ir);

		YulStack yulStack = parseYul(*ir);
		if (yulStack.hasErrors())
		{
			printYulErrors(yulStack, _stream, _linePrefix, _formatted);
			return TestResult::FatalError;
		}

		auto handleObject = [&](std::string const& _kind, Object const& _object) {
			auto const memoryGuardHandle = yulStack.dialect().findBuiltin("memoryguard");
			m_obtainedResult += contractName + "(" + _kind + ") ";
			if (memoryGuardHandle && !findFunctionCalls(
				_object.code()->root(),
				*memoryGuardHandle
			).empty())
				m_obtainedResult += "true\n";
			else
				m_obtainedResult += "false\n";
		};
		handleObject("creation", *yulStack.parserResult());
		size_t deployedIndex = yulStack.parserResult()->subIndexByName.at(
			IRNames::deployedObject(compiler().contractDefinition(contractName))
		);
		handleObject("runtime", dynamic_cast<Object const&>(*yulStack.parserResult()->subObjects[deployedIndex]));
	}
	return checkResult(_stream, _linePrefix, _formatted);
}
