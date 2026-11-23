# Solidity Commons Library (Solidity related sharing bits between libsolidity and libyul)
set(sources
	Common.h
	CharStream.cpp
	CharStream.h
	CodeSizeLimits.cpp
	CodeSizeLimits.h
	DebugData.h
	DebugInfoSelection.cpp
	DebugInfoSelection.h
	ErrorReporter.cpp
	ErrorReporter.h
	EthdebugJson.cpp
	EthdebugJson.h
	EthdebugSchema.cpp
	EthdebugSchema.h
	EVMVersion.h
	EVMVersion.cpp
	Exceptions.cpp
	Exceptions.h
	ParserBase.cpp
	ParserBase.h
	Scanner.cpp
	Scanner.h
	CharStreamProvider.h
	SemanticDebugData.h
	SemanticDebugDataSerialization.cpp
	SemanticDebugDataSerialization.h
	SemanticDebugDataTable.cpp
	SemanticDebugDataTable.h
	SemVerHandler.cpp
	SemVerHandler.h
	SourceLocation.h
	SourceLocation.cpp
	SourceReferenceExtractor.cpp
	SourceReferenceExtractor.h
	SourceReferenceFormatter.cpp
	SourceReferenceFormatter.h
	Token.cpp
	Token.h
	UniqueErrorReporter.h
)

add_library(langutil ${sources})
target_link_libraries(langutil PUBLIC solutil fmt::fmt-header-only)
