.. index:: ethdebug; implementation

.. _ethdebug-internals:

***********************
ethdebug Implementation
***********************

This page assumes familiarity with the :ref:`ethdebug output <ethdebug>`.
It follows the construction of resource tables from frontend analysis through schema serialization.
Traversal order and the expression trees built by the compiler are implementation details and may change.

.. note::
    The debug info that is passed from the Solidity frontend through Yul is specified in :doc:`ethdebug_internal_debug_info`.

Resource Collection
===================

``CompilerStack::ethdebug()`` calls ``frontend::ethdebug::resources()`` in ``libsolidity/interface/Ethdebug.cpp`` for each analyzed contract and merges the returned tables.
The merged tables are passed to ``evmasm::ethdebug::resources()``, which adds the compilation record and schema stamp.
``liblangutil/EthdebugSchema.h`` models the public schemas; the ``to_json()`` overloads in ``EthdebugSchema.cpp`` serialize those structures.

``CompilerStack::ethdebug()`` registers file-level variable declarations from the analyzed source units.
``frontend::ethdebug::resources()`` reads state-variable declarations from ``ContractDefinitionAnnotation::linearizedBaseContracts`` for type collection, including constants and immutables.
Pointer collection uses ``ContractType::linearizedStateVariables()`` to register storage and transient-storage layouts, excluding constants and immutables.

For callable declarations, it walks the edges of ``ContractDefinitionAnnotation::creationCallGraph`` and ``deployedCallGraph``.
Both callers and callees that are ``CallableDeclaration`` nodes are collected in a set ordered by AST ID.
``TypeRegistry::registerVariableTypes()`` registers the annotated type of every ``VariableDeclaration`` in each selected declaration's AST subtree.
``TypeRegistry::registerCallableTypes()`` additionally constructs tuple types from the callable's parameter list and non-empty return list using ``TypeProvider::tuple()``.
These go through the same registration path as the tuples used by function-type documents.
This includes parameters and return variables as well as body declarations and ``try``/``catch`` parameters without a separate traversal for each kind of statement.
The visitor stops at variable declarations: their component types are registered by ``TypeRegistry``, and their initializer expressions cannot contain further variable declarations.
It does not follow references to event, error or external-function declarations.

Type Registration
=================

``TypeRegistry::registerTypeDecomposition()`` in ``libsolidity/interface/EthdebugTypeRegistry.cpp`` canonicalizes a type with ``TypeProvider::withLocationIfReference(DataLocation::Storage, ...)`` before looking up its ``Type::identifier()``.
This makes the registry reuse an entry when it encounters the same reference type in another data location.

A lookup for an existing identifier returns immediately.
For a new identifier, the registry inserts a placeholder before visiting the component types and replaces it with the completed document afterwards.
A recursive component can therefore refer to the entry being built without restarting its construction.

``buildTypeDocument()`` dispatches on ``Type::Category`` and constructs the corresponding schema variant.
``registerAndWrapType()`` recursively registers a component's decomposition before creating its reference.
For function types, the parameter and return lists are first turned into tuple types with ``TypeProvider::tuple()`` and registered through the same path.
Struct members come from ``StructType::members(nullptr)``, which gives each member the type it has in the struct's data location.

For definition locations, ``buildSourceRange()`` resolves the source unit name through the source-index map supplied by ``CompilerStack`` and copies the range from ``SourceLocation``.

Pointer Template Construction
=============================

``PointerTemplateRegistry`` in ``libsolidity/interface/EthdebugPointerTemplateRegistry.cpp`` collects reachable template types in ``m_pendingTemplateTypes`` before building them.
Its keys combine the layout with ``TypeRegistry::canonicalizeType()``'s type identifier.
``registerVariableTypes()`` skips declarations without an implementation and registers reference and mapping variables in their annotated locations.
Scalar declarations in callable bodies are skipped because their type annotations do not specify a data location.
``collectTemplateTypes()`` follows component types in the same location as their enclosing type; it does not add layouts for other locations.
``registerType()`` always selects the next pending layout by pointer ID, including in recursive calls.
This keeps recursive templates independent of the order in which a contract's state variables register their types.

``m_templateIDsBeingBuilt`` records the IDs of templates under construction.
A reference to one of these uses its identifier without descending into it again.
Completed drafts are stored in ``m_templateDrafts`` and record their region names in ``TemplateDraft::producedRegions``.
``buildTemplateReference()`` uses those names to construct the ``yields`` map of a template reference.
For a reference to a template still being built, the names are not known yet and no ``yields`` map is added.

``buildStructTemplate()`` obtains each member's slot offset and little-endian byte offset from ``StructType::storageOffsetsOfMember()`` and passes the member to ``buildStorageComponentPointer()``.
``buildStorageComponentPointer()`` chooses between a value region and a template reference, binding the member's slot when needed.
Its mapping branch stops at a base-slot region; entry expansion is handled by ``buildMappingTemplate()``, which passes the mapping's value type back to ``buildStorageComponentPointer()``.

``buildArrayTemplate()`` dispatches to ``buildBytesOrStringPointer()`` for the short and long byte-array encodings and otherwise to the static or dynamic array builders.
Both array builders use ``buildArrayElementListPointer()`` for the element pointer.
It selects the packed-value case using ``Type::storageBytes()`` and obtains the stride of other elements from ``Type::storageSize()``.
``buildBytesOrStringPointer()`` constructs a conditional pointer and scopes the intermediate length and data-location expressions to the branch that uses them.

``buildByteAddressedTemplate()`` handles memory and calldata.
It obtains struct offsets from ``memoryOffsetOfMember()`` or ``calldataOffsetOfMember()`` and array strides from ``memoryStride()`` or ``calldataStride()``.
``buildByteAddressedComponentPointer()`` emits value regions using ``storageBytes()`` and ``leftAligned()``.
For reference-type components it reads the head word before binding the nested template's ``offset``: memory uses the word as an absolute address, whereas dynamically encoded calldata components add it to the enclosing tuple or array's element base.
Statically encoded calldata components bind their inline address directly.

The helpers in the ``pointer`` namespace construct schema expressions and pointers rather than Yul or assembly instructions.
``pointer::addLiteralOffset()`` folds additions to literal slots or byte addresses.
``pointer::buildValueRegion()`` converts little-endian byte offsets to big-endian byte offsets and omits redundant zero offsets and whole-word lengths.

Tests
=====

The fixtures under ``test/libsolidity/ethdebugTests/resources/`` pin the serialized type documents and pointer templates.
``test/ethdebugSchemaTests.py`` compiles the same fixtures and checks schema conformance, type references, template bindings and region names.
