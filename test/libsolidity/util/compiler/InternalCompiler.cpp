#include <test/libsolidity/util/compiler/InternalCompiler.h>

using namespace solidity;
using namespace solidity::frontend::test;

CompilerOutput InternalCompiler::compile(CompilerInput const& _input)
{
    configure(_input);
    
    auto [contracts, errors] = compile();
    auto output = CompilerOutput{
        contracts,
        success(),
        errors,
        formatErrorInformation()
    };
    return output;
}

void InternalCompiler::configure(CompilerInput const& _input)
{
    m_stack.reset();

    m_stack.setSources(_input.sourceCode);
    m_stack.setLibraries(_input.libraryAddresses);

    if (_input.evmVersion.has_value())
        m_stack.setEVMVersion(_input.evmVersion.value());
    if (_input.optimise.has_value())
        m_stack.setOptimiserSettings(_input.optimise.value());
    if (_input.optimiserSettings.has_value())
        m_stack.setOptimiserSettings(_input.optimiserSettings.value());
    if (_input.revertStrings.has_value())
        m_stack.setRevertStringBehaviour(_input.revertStrings.value());
    if (_input.metadataFormat.has_value())
    {
        auto metadata = CompilerStack::MetadataFormat::NoMetadata;
        switch (_input.metadataFormat.value())
        {
        case MetadataFormat::WithReleaseVersionTag:
            metadata = CompilerStack::MetadataFormat::WithReleaseVersionTag;
            break;
        case MetadataFormat::WithPrereleaseVersionTag:
            metadata = CompilerStack::MetadataFormat::WithPrereleaseVersionTag;
            break;
        
        default:
            break;
        }
        m_stack.setMetadataFormat(metadata);
    }
    if (_input.metadataHash.has_value())
    {
        auto hash = CompilerStack::MetadataHash::None;
        switch (_input.metadataHash.value())
        {
        case MetadataHash::IPFS:
            hash = CompilerStack::MetadataHash::IPFS;
            break;
        case MetadataHash::Bzzr1:
            hash = CompilerStack::MetadataHash::Bzzr1;
            break;
        
        default:
            break;
        }
        m_stack.setMetadataHash(hash);
    }	
    if (_input.viaIR.has_value())
        m_stack.setViaIR(_input.viaIR.value());
    m_stack.setEOFVersion(_input.eofVersion);
}

std::pair<MappedContracts, Errors> InternalCompiler::compile()
{
    m_stack.compile();

    auto mappedContracts = MappedContracts{};
    for (auto sourceName: m_stack.sourceNames())
    {	
        std::vector<CompiledContract> contracts;
        auto const& sourceUnit = m_stack.ast(sourceName);
        for (auto const* contract: ASTNode::filteredNodes<ContractDefinition>(sourceUnit.nodes()))
        {
            auto contractName = contract->fullyQualifiedName();
            auto object = m_stack.object(contractName);
            auto runtimeObject = m_stack.runtimeObject(contractName);
            auto hasUnlinkedReferences = !object.linkReferences.empty();
            auto assemblyItems = m_stack.assemblyItems(contractName);
            auto runtimeAssemblyItems = m_stack.runtimeAssemblyItems(contractName);
            auto metadata = m_stack.metadata(contractName);
            auto cborMetadata = m_stack.cborMetadata(contractName);
            auto contractABI = m_stack.contractABI(contractName);
            auto interfaceSymbols = m_stack.interfaceSymbols(contractName);
            auto eventSignatures = generateEventSignatures(contractName);

            auto compiledContract = CompiledContract{
                contractName,
                object.bytecode,
                runtimeObject.bytecode,
                hasUnlinkedReferences,
                assemblyItems != nullptr ? *assemblyItems : evmasm::AssemblyItems{},
                runtimeAssemblyItems != nullptr ? *runtimeAssemblyItems : evmasm::AssemblyItems{},
                metadata,
                cborMetadata,
                contractABI,
                interfaceSymbols,
                eventSignatures
            };
            contracts.emplace_back(compiledContract);
        }
        mappedContracts.insert(std::make_pair(sourceName, contracts));
    }
    return std::make_pair(mappedContracts, m_stack.errors());
}

bool InternalCompiler::success() const
{
    return m_stack.compilationSuccessful();
}

std::vector<AnnotatedEventSignature> InternalCompiler::generateEventSignatures(
    std::string const& _contractName
) const
{
    std::vector<AnnotatedEventSignature> signatures;
    ContractDefinition const& contract = m_stack.contractDefinition(_contractName);
    for (EventDefinition const* event: contract.events() + contract.usedInterfaceEvents())
    {
        AnnotatedEventSignature eventInfo;
        auto eventFunctionType = event->functionType(true);

        eventInfo.signature = eventFunctionType->externalSignature();
        for (auto const& param: event->parameters())
            if (param->isIndexed())
                eventInfo.indexedTypes.emplace_back(param->type()->toString(true));
            else
                eventInfo.nonIndexedTypes.emplace_back(param->type()->toString(true));
        signatures.push_back(eventInfo);
    }
    return signatures;
}

std::string InternalCompiler::formatErrorInformation() const
{
    std::string errorInformation;
    for (auto const& error: m_stack.errors())
    {
        auto formatted = SourceReferenceFormatter::formatErrorInformation(
            *error.get(),
            m_stack,
            true,
            false
        );
        errorInformation.append(formatted);
    }
    return errorInformation;
}