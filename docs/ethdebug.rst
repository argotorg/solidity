.. index:: ! ethdebug, ! debug info, debugger

.. _ethdebug:

***************
ethdebug Output
***************

.. warning::

   ethdebug support is :ref:`experimental <experimental-mode>`.

The compiler can describe its output in the `ethdebug format <https://ethdebug.github.io/format/>`_, a JSON format for debugging information shared between compilers and debuggers.
The compiler targets version `0.1.0-draft.2 <https://github.com/ethdebug/format/tree/@ethdebug/format@0.1.0-draft.2>`_ of the format, which is still in development, and names it in the ``ethdebug`` stamp of the program and resources outputs.
The format defines a `schema <https://github.com/ethdebug/format/tree/@ethdebug/format@0.1.0-draft.2/schemas>`_ for each kind of document.
This page describes the compiler outputs and how to resolve their type and pointer references.
The options to request the outputs are documented in :ref:`compiler-api` and :ref:`commandline-compiler`.

Outputs
=======

+-------------------+-------------------------------------------+---------------------------------+---------------------------------------------+
| Document          | Standard JSON output                      | Command line                    | Schema                                      |
+===================+===========================================+=================================+=============================================+
| compilation       | ``ethdebug.compilation`` (global)         | ``--ethdebug-compilation``      | `ethdebug/format/materials/compilation`_    |
+-------------------+-------------------------------------------+---------------------------------+---------------------------------------------+
| resources         | ``ethdebug.resources`` (global)           | ``--ethdebug-resources``        | `ethdebug/format/info/resources`_           |
+-------------------+-------------------------------------------+---------------------------------+---------------------------------------------+
| creation program  | ``evm.bytecode.ethdebug`` (per contract)  | ``--ethdebug-program``          | `ethdebug/format/program`_                  |
+-------------------+-------------------------------------------+---------------------------------+---------------------------------------------+
| deployed program  | ``evm.deployedBytecode.ethdebug``         | ``--ethdebug-program-runtime``  | `ethdebug/format/program`_                  |
|                   | (per contract)                            |                                 |                                             |
+-------------------+-------------------------------------------+---------------------------------+---------------------------------------------+

.. _ethdebug/format/materials/compilation: https://github.com/ethdebug/format/blob/@ethdebug/format@0.1.0-draft.2/schemas/materials/compilation.schema.yaml
.. _ethdebug/format/info/resources: https://github.com/ethdebug/format/blob/@ethdebug/format@0.1.0-draft.2/schemas/info/resources.schema.yaml
.. _ethdebug/format/program: https://github.com/ethdebug/format/blob/@ethdebug/format@0.1.0-draft.2/schemas/program.schema.yaml

The compilation needs nothing but the sources.
The resources are derived from the analysis of the sources and the programs describe bytecode, so the latter can only be produced when compiling via IR.

The Compilation
===============

The compilation document identifies one run of the compiler and has an ``id`` derived from the sources, the ``compiler`` name and version and the list of ``sources``.
Every source carries its ``id``, ``path``, ``contents`` and ``language``.
A source ``id`` is a number unique within the compilation, and all source references in the other documents refer to sources by it.
Source references include their type explicitly, for example ``{"id": 0, "type": "source"}``.
The compiler currently uses the same number as the ``id`` of the source in the Standard JSON output and in :doc:`source mappings <internals/source_mappings>`.

The Resources
=============

The resources document carries its ``ethdebug`` stamp and two tables that the programs refer to: ``types`` and ``pointers``.
Compiler information and sources are provided separately by ``ethdebug.compilation``.
The resources and compilation outputs are only available for Solidity input.
Both tables cover all contracts of the compilation.

.. code-block:: json

    {
        "ethdebug": {
            "schema": "ethdebug/format/info/resources",
            "version": "0.1.0-draft.2"
        },
        "types": {
            "t_uint256": {
                "kind": "uint",
                "bits": 256
            },
            "...": "..."
        },
        "pointers": {
            "storage-t_struct$_Point_$6_storage": {
                "expect": [
                    "slot"
                ],
                "for": {
                    "group": [
                        "..."
                    ]
                }
            },
            "...": "..."
        }
    }

Type Documents
--------------

The ``types`` table maps type identifiers to type documents (schema ``ethdebug/format/type``).
The compiler currently uses the identifiers its :ref:`storage layout <storage-layout-top-level>` output uses as well, such as ``t_uint256``, ``t_array$_t_uint8_$dyn_storage`` or ``t_struct$_Point_$6_storage``.
The only guarantee about the identifier is that it is a string that is unique within the table.
Its exact form is an implementation detail, but it is generally based on the name used in type definition.
When that name is not unique within the compilation, it may be disambiguated with additional information, such as the AST ID of the definition.

The table contains documents for the types of:

- all state variables, including inherited variables, constants and immutables,
- all file-level constants in the analyzed sources,
- parameters, return variables and local variables of functions and modifiers in each contract's creation and deployed call graphs.

The last group includes constructors, public and external functions, fallback and receive functions, their modifiers, and the internal functions they call, including free and library functions.
An internal function also contributes its variable types if it is assigned to a function variable (``callback = f``) or merely evaluated (``f;``), even without a call.
Internal functions called or evaluated in state-variable initializers are included as well.
Collection happens before optimization, so it also includes declarations in code that is later removed.
Parameters and return variables of interface functions and other unimplemented functions are included even though those declarations have no bytecode.
Locals include variables in nested blocks and loops and the success and failure parameters of ``try``/``catch`` clauses.

The tables are merged across all analyzed contracts and sources, not just the contracts selected for bytecode output.
A selective import therefore does not exclude types contributed by other contracts or file-level constants in the imported source.
Taking an external function's ``selector`` or ``address`` does not add its variable types to the caller's table, but the function's own contract or interface still contributes them to the merged table.

Event and error parameters do not independently contribute types.
Neither do unused type definitions or types mentioned only in expressions, such as conversions, ``new``, struct constructors, builtins like ``bytes.concat()`` or parameters of ``abi.decode()``.
A ``using for`` directive alone does not contribute types.
Its internal functions contribute variable types when called or evaluated as function values, not merely because the directive names them.
Every collected type also brings in its component types, recursively.
The parameter lists and non-empty return lists of included functions and modifiers also have tuple documents, using the same representation as the lists in function types.
Each parameter and return variable still has its own type.
The tuple describes the list, not an extra variable.
Including a type does not imply that a variable's runtime location or value is available in the program output.
Unnameable types have no document.
These include literal types, array slice types, types of types, modifier types, magic types (such as those of ``msg`` and ``abi``), module types, inaccessible dynamic types and function types other than internal and external ones.
Library names cannot be used as variable types, so no library type document is emitted.

.. list-table::
   :header-rows: 1

   * - Solidity type
     - ethdebug representation
   * - ``uintN``, ``intN``
     - ``uint``, ``int`` with ``bits`` equal to ``N``
   * - ``bool``
     - ``bool``
   * - ``address``, ``address payable``
     - ``address`` with ``payable`` set to ``false`` or ``true``
   * - ``bytesN``, ``bytes``
     - ``bytes`` with ``size`` equal to ``N`` for fixed-size byte arrays and absent for dynamic ones
   * - ``string``
     - ``string``
   * - ``fixedMxN``, ``ufixedMxN``
     - ``fixed``, ``ufixed`` with ``bits`` equal to ``M`` and ``places`` equal to ``N``
   * - contract, interface
     - ``contract`` with ``payable`` and, for an interface, ``interface: true``
   * - enum
     - ``enum`` with ``values`` in declaration order
   * - user-defined value type ``type U is V``
     - ``alias`` with ``contains`` referencing ``V``
   * - ``T[N]``, ``T[]``
     - ``array`` with ``contains`` referencing ``T`` and ``count`` equal to ``N`` for a static array, absent for a dynamic one
   * - ``mapping(K => V)``
     - ``mapping`` with ``contains.key`` and ``contains.value`` referencing ``K`` and ``V``
   * - struct
     - ``struct`` with ``contains`` listing the members by ``name`` and type
   * - parameter or return list
     - ``tuple`` with ``contains`` listing the component types
   * - internal or external function type
     - ``function`` with ``internal: true`` or ``external: true``, ``contains.parameters`` referencing a tuple and ``contains.returns`` referencing a tuple when there are return values

Composite types reference their components by identifier, so that the table is closed:
an array, a mapping or a user-defined value type refers to its element, key, value or underlying type as ``{"type": {"id": "<id>"}}`` and a struct lists its members with their ``name`` and such a reference.
In a function type, ``contains.parameters`` always references the tuple of parameter types in declaration order.
No parameters means an empty tuple.
One parameter means a one-element tuple, not the parameter's type on its own.
``contains.returns`` follows the same convention for return types, but is omitted when there are no return values.
The outer tuple groups the list.
Classic Solidity does not support tuple-valued parameters or return variables.
Such a parameter or return variable would occupy one element referencing another tuple rather than being flattened into the list.
The tuple documents themselves also reference their components by identifier.
Neither the parameter nor return types are inlined.

Structs, enums, contracts and user-defined value types carry a ``definition`` with the ``name`` of the definition and its ``location`` in the source: the source ``id`` and the ``offset`` and ``length`` of the definition.
Function types in the table are types of variables, such as ``function (uint256) external returns (bool) f``, and are not associated with a fixed function definition, so they have no ``definition``.
Like in source mappings, and as the schema of source ranges specifies, the offset and the length count bytes of the UTF-8 encoded source, not characters.

A type document does not depend on where a value is stored.
That is what the pointer describes.
The variants of a reference type in different data locations therefore share one document: a ``string memory`` parameter and a ``string`` state variable both refer to the same entry.
An import alias also refers to the original type document.
It does not introduce another type or change the name in its ``definition``.

Pointer Templates
-----------------

The ``pointers`` table contains pointer templates (schema ``ethdebug/format/pointer/template``) describing how values are laid out in storage, transient storage, memory and calldata.
Mutable state variables contribute their storage or transient-storage layouts.
Reference and mapping variables in implemented functions and modifiers contribute the layouts specified by their declarations.
The component types of arrays, structs and mappings also have templates in the enclosing value's location.
Other layouts of the same type are not included unless another declaration needs them.
Scalar parameters, return variables and locals do not add data-layout templates.
Constants, immutables and function or modifier declarations without a body contribute type information but no pointer templates.
The compiler currently prefixes the canonical type identifier with the layout, for example ``storage-t_uint16``, ``memory-t_uint16`` and ``calldata-t_uint16``.
These are distinct pointer IDs referring to layouts of the same type document, ``t_uint16``.
Pointer IDs and type IDs are not interchangeable.

Storage and transient-storage templates expect ``slot`` as a parameter: the base slot of the value they describe.
Value-type templates additionally expect ``offset`` as a parameter: the *little-endian offset*, counted in bytes from the least significant byte, as in Solidity's storage layout.
For an *n*-byte value, this offset must be between 0 and ``32 - n``.
Memory and calldata templates instead expect ``offset`` as a parameter: the byte address at which the value begins.
For a dynamic array, ``bytes`` or ``string``, this includes the length word.
For a static array or struct it is the start of the first element or member.
For an ABI-encoded dynamic value, bind the address of its tail, not the address of the head word containing the relative offset.

Memory templates follow the absolute pointers stored in reference-type members and array elements.
Calldata templates follow ABI-relative offsets, and keep statically encoded structs and arrays inline.
Values narrower than a word are padded in memory and calldata rather than packed: numeric values occupy the low-order bytes, while ``bytesN`` and external function values occupy the high-order bytes.
The templates describe these regions explicitly.

Templates describe layouts, not the location or lifetime of individual variables.
A consumer must obtain the base address or slot, and any little-endian offset, from a variable pointer or another location record before instantiating a template.

The template of a mapping also expects ``key`` as a parameter: the key of the entry it locates.
The value of a mapping is not at a fixed place, and a mapping nested in another type is represented by the region of its base slot, from which the mapping's template locates an entry once a key is bound.
A key of value type is bound to the word it is hashed as, which is the word Solidity holds it in on the stack: a signed integer sign-extended, a ``bytesN`` in the high-order bytes followed by zeros, and any other value type in the low-order bytes.
The template widens a shorter value with zeros on the left, which is correct for low-order-aligned keys that need zero padding.
A ``bytes4`` key needs padding on the right and a negative ``int8`` key needs sign extension, so bind these as whole words.
A ``bytes`` or ``string`` key is bound to its bytes, which are hashed as they are.
A recursive type (one nested in itself, through an array or through a mapping) references its own template, which a debugger follows as far as the data reaches: one element per list entry, one key per mapping level.

The choice of region names and pointer expressions can change between compiler versions.
Consumers should read them from the templates.
The compiler currently names regions relative to the value a template describes:

- the members of a struct: their names,
- the elements of an array: ``item``, with ``index`` being the variable the list iterates over,
- the length of a dynamic array: ``length``,
- a standalone value type: ``value``,
- the parts of a storage ``bytes`` or ``string``: ``length-flag``, ``long-length`` and ``data``,
- the parts of a memory or calldata ``bytes`` or ``string``: ``length`` and ``data``,
- the pointer or relative-offset word of a nested reference value: ``<member>-address`` or ``item-address``.

For non-recursive references, a template referencing the template of a member's or element's type prefixes the names that one produces with the member's name or ``item``, so that the ``x`` of the ``from`` member of a ``Line`` is ``from-x`` and that of an element of a ``Point[]`` is ``item-x``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    struct Point { uint8 x; uint8 y; }
    struct Line { Point from; Point to; }

    contract C {
        uint256 total;
        Point origin;
        mapping(address => uint256) balances;
        Line line;
    }

The following entries describe ``total``, ``origin``, entries of ``balances`` and ``line`` in storage.
The storage layout puts ``total`` at slot 0, with little-endian offset 0.
A region's ``offset`` is a *big-endian offset*, counted from the most significant byte of its slot.
The two members of ``Point`` share a slot, with ``x`` at big-endian offset 31 and ``y`` at 30.
A debugger instantiates the ``Point`` template with ``slot`` bound to 1, where the layout puts ``origin``, and the mapping's template with ``slot`` bound to 2 and ``key`` to the address of the entry it wants to see.
The ``Line`` template is instantiated with ``slot`` bound to 3.
Its ``yields`` maps distinguish ``from-x`` and ``from-y`` from ``to-x`` and ``to-y``.

.. code-block:: json

    {
        "storage-t_uint256": {
            "expect": [
                "slot",
                "offset"
            ],
            "for": {
                "location": "storage",
                "name": "value",
                "slot": "slot",
                "offset": {
                    "~difference": [
                        "0x00",
                        "offset"
                    ]
                },
                "length": "0x20"
            }
        },
        "storage-t_struct$_Point_$6_storage": {
            "expect": [
                "slot"
            ],
            "for": {
                "group": [
                    {
                        "location": "storage",
                        "name": "x",
                        "slot": "slot",
                        "offset": "0x1f",
                        "length": "0x01"
                    },
                    {
                        "location": "storage",
                        "name": "y",
                        "slot": "slot",
                        "offset": "0x1e",
                        "length": "0x01"
                    }
                ]
            }
        },
        "storage-t_mapping$_t_address_$_t_uint256_$": {
            "expect": [
                "slot",
                "key"
            ],
            "for": {
                "location": "storage",
                "name": "value",
                "slot": {
                    "~keccak256": [
                        {
                            "~wordsized": "key"
                        },
                        {
                            "~wordsized": "slot"
                        }
                    ]
                }
            }
        },
        "storage-t_struct$_Line_$13_storage": {
            "expect": [
                "slot"
            ],
            "for": {
                "group": [
                    {
                        "template": "storage-t_struct$_Point_$6_storage",
                        "yields": {
                            "x": "from-x",
                            "y": "from-y"
                        }
                    },
                    {
                        "define": {
                            "slot": {
                                "~sum": [
                                    "slot",
                                    "0x01"
                                ]
                            }
                        },
                        "in": {
                            "template": "storage-t_struct$_Point_$6_storage",
                            "yields": {
                                "x": "to-x",
                                "y": "to-y"
                            }
                        }
                    }
                ]
            }
        }
    }

.. warning::

   A region's ``offset`` is a big-endian offset, counted from the most significant byte of the slot.
   The ``offset`` in Solidity's :ref:`storage layout <storage-layout-top-level>` is a little-endian offset, counted from the least significant byte.
   For a value of *n* bytes contained in a single slot, little-endian offset *o* corresponds to big-endian offset 32 - *o* - *n*.

   Solidity's offsets follow the order in which values are packed, starting at the low-order end.
   Either direction works within a single slot, but ETHDebug's `segment addressing scheme <https://github.com/ethdebug/format/blob/main/schemas/pointer/scheme/segment.schema.yaml>`_ also allows a region to span consecutive slots.
   It treats each slot as a big-endian byte sequence, continuing from the least significant byte of slot ``p`` to the most significant byte of slot ``p + 1``.

The Programs
============

A program (schema ``ethdebug/format/program``) describes bytecode of one contract: either its creation bytecode or its deployed bytecode.
It names the ``contract`` and the source range of its definition, states the ``environment`` the bytecode runs in, ``create`` or ``call``, and lists its ``instructions``.
Every instruction carries its byte ``offset`` in the bytecode, the ``operation`` with the ``mnemonic`` of the opcode and the ``arguments`` of a push, and, where the compiler knows it, a ``context`` with the source range of the code the instruction was generated from.
