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

#include <libyul/AsmAnalysisInfo.h>
#include <libyul/AsmAnalysis.h>
#include <libyul/Dialect.h>
#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/YulStack.h>
#include <libyul/AST.h>

#include <liblangutil/DebugInfoSelection.h>
#include <liblangutil/Exceptions.h>
#include <liblangutil/EVMVersion.h>

#include <libsolutil/CommonIO.h>
#include <libsolutil/CommonData.h>
#include <libsolutil/StringUtils.h>

#include <test/tools/ossfuzz/yulFuzzerCommon.h>

#include <string>
#include <memory>
#include <iostream>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::yul::test::yul_fuzzer;

// Prototype as we can't use the FuzzerInterface.h header.
extern "C" int LLVMFuzzerTestOneInput(uint8_t const* _data, size_t _size);

extern "C" int LLVMFuzzerTestOneInput(uint8_t const* _data, size_t _size)
{
	if (_size > 600)
		return 0;

	std::string input(reinterpret_cast<char const*>(_data), _size);

	if (std::any_of(input.begin(), input.end(), [](char c) {
		return ((static_cast<unsigned char>(c) > 127) || !(isPrint(c) || (c == '\n') || (c == '\t')));
	}))
		return 0;

	YulStringRepository::reset();

	YulStack stack(
		langutil::EVMVersion(),
		std::nullopt,
		YulStack::Language::StrictAssembly,
		solidity::frontend::OptimiserSettings::full(),
		DebugInfoSelection::AllExceptExperimental()
	);
	try
	{
		if (
			!stack.parseAndAnalyze("source", input) ||
			!stack.parserResult()->hasCode() ||
			!stack.parserResult()->analysisInfo
		)
			return 0;
	}
	catch (Exception const&)
	{
		return 0;
	}
    const bytes calldata = {
            0xe9, 0x96, 0x40, 0x7d, 0xa5, 0xda, 0xb0, 0x2d,
            0x97, 0xf5, 0xc3, 0x44, 0xd7, 0x65, 0x0a, 0xd8,
            0x2c, 0x14, 0x3a, 0xf3, 0xe7, 0x40, 0x0f, 0x1e,
            0x67, 0xce, 0x90, 0x44, 0x2e, 0x92, 0xdb, 0x88,
            0xb8, 0x43, 0x9c, 0x41, 0x42, 0x08, 0xf1, 0xd7,
            0x65, 0xe9, 0x7f, 0xeb, 0x7b, 0xb9, 0x56, 0x9f,
            0xc7, 0x60, 0x5f, 0x7c, 0xcd, 0xfb, 0x92, 0xcd,
            0x8e, 0xf3, 0x9b, 0xe4, 0x4f, 0x6c, 0x14, 0xde
    };

	std::ostringstream os1;
	std::ostringstream os2;
	// Disable memory tracing to avoid false positive reports
	// such as unused write to memory e.g.,
	// { mstore(0, 1) }
	// that would be removed by the redundant store eliminator.
	// TODO: Add EOF support
	yulFuzzerUtil::TerminationReason termReason = yulFuzzerUtil::interpret(
		os1,
		calldata,
		*stack.parserResult()->code(),
		/*disableMemoryTracing=*/true
	);
	if (yulFuzzerUtil::resourceLimitsExceeded(termReason))
		return 0;

	stack.optimize();
	termReason = yulFuzzerUtil::interpret(
		os2,
		calldata,
		*stack.parserResult()->code(),
		/*disableMemoryTracing=*/true
	);

	if (yulFuzzerUtil::resourceLimitsExceeded(termReason))
		return 0;

	bool isTraceEq = (os1.str() == os2.str());
	yulAssert(isTraceEq, "Interpreted traces for optimized and unoptimized code differ.");
	return 0;
}
