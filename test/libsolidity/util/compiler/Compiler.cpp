#include <test/libsolidity/util/compiler/Compiler.h>

using namespace solidity;
using namespace solidity::frontend::test;

std::optional<CompiledContract> CompilerOutput::contract(
    std::optional<std::string> _sourceName,
    std::optional<std::string> _contractName
) const
{	
    std::vector<CompiledContract> contracts;
    
    // Find contracts for specific source name, if set. Otherwise,
    // find contracts for the empty source name.
    auto sourceName = _sourceName.value_or("");
    auto pos = m_sourceUnits.find(sourceName);
    if (pos != m_sourceUnits.end())
        contracts = pos->second;

    if (contracts.empty())
        return std::nullopt;

    // Return specific contract if name was set, or last in the list.
    if (_contractName.has_value())
    {
        for (auto const& contract: contracts)
            if (
                _contractName.value().compare(contract.name) ||
                _contractName.value().compare(":" + contract.name)
            )
                return std::make_optional(contract);
        return std::nullopt;
    }
    else
    {
        auto contract = contracts.back();
        return std::make_optional(contract);
    }
}

std::optional<AnnotatedEventSignature> CompilerOutput::matchEvent(
    util::h256 const& _hash
) const
{
    for (auto const& [name, contracts]: m_sourceUnits)
        for (auto const& contract: contracts)
            for (auto const& event: contract.eventSignatures)
                if (keccak256(event.signature) == _hash)
                    return std::make_optional(event);

    return std::nullopt;
}

bool CompilerOutput::success() const
{
    return m_success;
}

std::optional<langutil::Error> CompilerOutput::findError(
    langutil::Error::Type _type
) const
{
    for (auto const& error: m_errors)
		if (error->type() == _type)
			return std::make_optional(*error);

    return std::nullopt;
}

std::string CompilerOutput::errorInformation() const 
{
    return m_errorInformation;
}