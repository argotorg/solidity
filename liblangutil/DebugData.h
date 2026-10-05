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

#include <liblangutil/SourceLocation.h>
#include <optional>
#include <memory>
#include <utility>

namespace solidity::langutil
{

struct SemanticDebugScope;

struct DebugData
{
	typedef typename std::shared_ptr<DebugData const> ConstPtr;

	explicit DebugData(
		langutil::SourceLocation _nativeLocation = {},
		langutil::SourceLocation _originLocation = {},
		std::optional<int64_t> _astID = {},
		std::optional<int64_t> _astIDInstance = {},
		std::shared_ptr<SemanticDebugScope const> _semanticDebugScope = {}
	):
		nativeLocation(std::move(_nativeLocation)),
		originLocation(std::move(_originLocation)),
		astID(_astID),
		astIDInstance(_astIDInstance),
		semanticDebugScope(std::move(_semanticDebugScope))
	{}

	static DebugData::ConstPtr create(
		langutil::SourceLocation _nativeLocation,
		langutil::SourceLocation _originLocation = {},
		std::optional<int64_t> _astID = {},
		std::optional<int64_t> _astIDInstance = {},
		std::shared_ptr<SemanticDebugScope const> _semanticDebugScope = {}
	)
	{
		return std::make_shared<DebugData>(
			std::move(_nativeLocation),
			std::move(_originLocation),
			_astID,
			_astIDInstance,
			std::move(_semanticDebugScope)
		);
	}

	static DebugData::ConstPtr create()
	{
		static DebugData::ConstPtr emptyDebugData = create({});
		return emptyDebugData;
	}

	/// The locations of @a _debugData without its source-language identity:
	/// for nodes the compiler generates rather than derives from a source node,
	/// which must not inherit the AST ID, instance or semantic scope.
	static DebugData::ConstPtr locationsOnly(DebugData::ConstPtr const& _debugData)
	{
		if (!_debugData)
			return create();
		return create(_debugData->nativeLocation, _debugData->originLocation);
	}

	/// Location in the Yul code.
	langutil::SourceLocation nativeLocation;
	/// Location in the original source that the Yul code was produced from.
	/// Optional. Only present if the Yul source contains location annotations.
	langutil::SourceLocation originLocation;
	/// ID in the (Solidity) source AST.
	std::optional<int64_t> astID;
	/// Discriminator of the generated scope instance among those sharing
	/// @a astID, carried in Yul text by the `@ast-id-instance` annotation.
	/// Unset or zero for code that has not been cloned.
	std::optional<int64_t> astIDInstance;
	/// Semantic scope record attached to this node. It has no Yul comment
	/// form and travels in the ethdebug sidecar instead
	/// (see liblangutil/SemanticDebugData.h).
	std::shared_ptr<SemanticDebugScope const> semanticDebugScope;
};

} // namespace solidity::langutil
