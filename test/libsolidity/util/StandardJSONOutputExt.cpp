#include <test/libsolidity/util/StandardJSONOutputExt.h>

#include <liblangutil/Exceptions.h>

#include <range/v3/algorithm.hpp>

#include <vector>

#include <fmt/base.h>

#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/map.hpp>
#include <range/v3/view/transform.hpp>

#include <test/libsolidity/util/SoltestErrors.h>

using namespace solidity;
using namespace solidity::frontend::test;
using namespace solidity::frontend::test::output;

bool StandardJSONOutputExt::success() const
{
	return !ranges::any_of(errors(), [](auto const& e) {
		return e.type != langutil::Error::Type::Info && e.type != langutil::Error::Type::Warning;
	});
}

std::vector<Error> const& StandardJSONOutputExt::errors() const
{
	return m_base.errors;
}

std::vector<Contract const*> const StandardJSONOutputExt::contracts() const
{
	auto sourceUnits = m_base.contracts | ranges::views::values;
	auto contracts = sourceUnits | ranges::views::transform([](auto& contracts) {
		return contracts | ranges::views::values;
	}) | ranges::views::join;
	return contracts | ranges::views::transform([](Contract const& contract) {
		return &contract;
	}) | ranges::to<std::vector<Contract const*>>();
}

Contract const* StandardJSONOutputExt::contract(ContractName const& _name) const
{
	auto const& sourceUnits = m_base.contracts;
	auto const [sourceName, contractName] = std::pair{std::string{_name.source()}, _name.contract()};

	auto source = sourceUnits.find(sourceName);
	if (source == sourceUnits.end())
	    return nullptr;

	auto const& contracts = source->second;
	if (contracts.empty())
    	return nullptr;

	if (!contractName.empty())
	{
		auto contract = contracts.find(std::string{contractName});
		return (contract != contracts.end()) ? &contract->second : nullptr;
	}
	else
	{
		soltestAssert(contracts.size() == 1, "Empty contract names only allowed for sources with a single contract definition");
		return &contracts.begin()->second;
	}
}
