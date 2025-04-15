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
* @file BlockSorter.cpp
* @author rodiazet <rodiazet@ethereum.com>
* @date 2025
* Sorts block topologically.
*/

#include <libevmasm/BlockSorter.h>

#include <libevmasm/AssemblyItem.h>
#include <libevmasm/SemanticInformation.h>

#include <set>
#include <range/v3/view/reverse.hpp>

using namespace solidity;
using namespace solidity::evmasm;

namespace
{

struct Block
{
	std::vector<Block*> children;
	AssemblyItems items;
};

class ControlFlowGraph
{
	std::list<Block> m_blocks;
	Block* m_entry = {};

public:
	static ControlFlowGraph build(AssemblyItems const& items)
	{
		ControlFlowGraph cfg;
		if (items.empty())
			return cfg;

		std::map<AssemblyItem, Block*> tagToBlock;

		auto const rootTag
			= items.front().type() == Tag ? items.front() : AssemblyItem(Tag, std::numeric_limits<u256>::max());

		Block* currentBlock = &cfg.m_blocks.emplace_back(Block{});
		cfg.m_entry = currentBlock;

		tagToBlock.insert({rootTag, currentBlock});

		for (size_t i = 0; i < items.size(); ++i)
		{
			auto const& item = items[i];

			// Each new block has to start with a tag.
			solAssert(currentBlock != nullptr || item.type() == Tag);
			if (item.type() == Tag)
			{
				auto const prevBlock = currentBlock;
				if (auto blockIt = tagToBlock.find(item); blockIt != tagToBlock.end())
					currentBlock = blockIt->second;
				else
				{
					currentBlock = &cfg.m_blocks.emplace_back(Block{{}, {}});
					tagToBlock.insert({item, currentBlock});
				}

				if (prevBlock != nullptr)
				{
					// If previous block hasn't finished with RJUMP (or terminating instruction) add RJUMP to the tag starting new block.
					prevBlock->children.push_back(currentBlock);
					prevBlock->items.push_back(AssemblyItem::relativeJumpTo(item));
				}
			}
			else if (item.type() == RelativeJump || item.type() == ConditionalRelativeJump)
			{
				if (auto blockIt = tagToBlock.find(item.tag()); blockIt != tagToBlock.end())
					currentBlock->children.push_back(blockIt->second);
				else
				{
					currentBlock->children.push_back(&cfg.m_blocks.emplace_back(Block{{}, {}}));
					tagToBlock.insert({item.tag(), &cfg.m_blocks.back()});
				}
			}

			solAssert(currentBlock != nullptr);
			currentBlock->items.push_back(item);

			if (
				SemanticInformation::altersControlFlow(item) &&
				item.type() != CallF &&
				item.type() != ConditionalRelativeJump
			)
				currentBlock = nullptr;
		}

		return cfg;
	}

	AssemblyItems sort() const
	{
		AssemblyItems result;

		std::vector<Block const*> sortedBlocks;
		std::set<Block const*> visited;

		std::function<void(Block const* block)> dfs = [&](Block const* block){
			visited.insert(block);
			for (auto const& childBlock: block->children)
			{
				if (!visited.count(childBlock))
					dfs(childBlock);
			}
			sortedBlocks.push_back(block);
		};

		dfs(m_entry);

		for (auto const& block: sortedBlocks | ranges::views::reverse)
		{
			for (auto&& item: block->items)
				result.emplace_back(item);
		}

		return result;
	}
};
}

void BlockSorter::sort()
{
	auto cfg = ControlFlowGraph::build(m_items);
	m_items = cfg.sort();
}
