// SPDX-License-Identifier: GPL-3.0
/**
 * @file SubroutineEntryMarker.h
 * Post-optimisation pass for EIP-7979 code: a tag that is reached from more
 * than one subroutine entry becomes a subroutine entry itself (CALLDEST),
 * so that code shared by several subroutines is entered as a subroutine
 * (EIP-8337, constraint 5). A CALLDEST costs what a JUMPDEST costs.
 */

#pragma once

#include <libevmasm/AssemblyItem.h>

namespace solidity::evmasm
{

class SubroutineEntryMarker
{
public:
	/// Marks every tag reached from more than one entry as a subroutine entry.
	/// @returns true if any tag was marked.
	static bool markSharedBlocks(AssemblyItems& _items);
};

}
