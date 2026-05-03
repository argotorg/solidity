"""
Synthetic Solidity contract generator for the solc benchmarking infrastructure.

Produces parameterised .sol files covering five stress categories that exercise
distinct compiler subsystems.  All code uses Python stdlib only.

Usage:
    from pathlib import Path
    from contract_generator import StressCategory, generate

    path = generate(StressCategory.DEEP_NESTING, size=10, output_dir=Path("generated"))
"""

from __future__ import annotations

from enum import Enum
from pathlib import Path

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

_SPDX = "// SPDX-License-Identifier: GPL-3.0"
_PRAGMA = "pragma solidity ^0.8.0;"
_DEFAULT_SIZE = 10


class StressCategory(Enum):
    """The five synthetic contract families."""

    DEEP_NESTING = "deep-nesting"
    WIDE_CONTRACT = "wide-contract"
    HEAVY_ABI = "heavy-abi"
    COMPLEX_CONTROL_FLOW = "complex-control-flow"
    HEAVY_STORAGE = "heavy-storage"


def generate(
    category: StressCategory,
    size: int = _DEFAULT_SIZE,
    output_dir: Path = Path("generated"),
) -> Path:
    """Generate a .sol file for *category* at the given *size*.

    Creates *output_dir* (including parents) if it does not exist, writes the
    Solidity source, and returns the path to the written file.

    Args:
        category:   Which stress category to generate.
        size:       Positive integer that scales contract complexity.
        output_dir: Directory in which to write the .sol file.

    Returns:
        Path to the generated .sol file.
    """
    if size < 1:
        raise ValueError(f"size must be a positive integer, got {size!r}")

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    _generators = {
        StressCategory.DEEP_NESTING: _generate_deep_nesting,
        StressCategory.WIDE_CONTRACT: _generate_wide_contract,
        StressCategory.HEAVY_ABI: _generate_heavy_abi,
        StressCategory.COMPLEX_CONTROL_FLOW: _generate_complex_control_flow,
        StressCategory.HEAVY_STORAGE: _generate_heavy_storage,
    }

    source = _generators[category](size)
    filename = f"{category.value}.sol"
    out_path = output_dir / filename
    out_path.write_text(source, encoding="utf-8")
    return out_path


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

def _header(contract_name: str) -> str:
    """Return the standard file header (SPDX + pragma + contract opening)."""
    return f"{_SPDX}\n{_PRAGMA}\n\ncontract {contract_name} {{\n"


def _footer() -> str:
    return "}\n"


# ---------------------------------------------------------------------------
# Category generators
# ---------------------------------------------------------------------------

def _generate_deep_nesting(size: int) -> str:
    """Nested structs, mappings, and functions scaled by *size*.

    Generates *size* levels of nested struct definitions and a set of
    functions that read/write them, exercising the type checker and ABI
    encoder.
    """
    lines: list[str] = []
    lines.append(_SPDX)
    lines.append(_PRAGMA)
    lines.append("")
    lines.append("contract DeepNesting {")
    lines.append("")

    # Generate nested struct definitions: S1 contains S2, S2 contains S3, …
    # The innermost struct holds a uint256 value field.
    for i in range(size, 0, -1):
        lines.append(f"    struct S{i} {{")
        if i < size:
            lines.append(f"        S{i + 1} inner;")
        lines.append(f"        uint256 val{i};")
        lines.append("    }")
        lines.append("")

    # A mapping from uint256 to the outermost struct
    lines.append("    mapping(uint256 => S1) public store;")
    lines.append("")

    # Nested mappings: map1 -> map2 -> … -> uint256
    for i in range(1, size + 1):
        mapping_type = "uint256"
        for _ in range(i):
            mapping_type = f"mapping(uint256 => {mapping_type})"
        lines.append(f"    {mapping_type} public nestedMap{i};")
    lines.append("")

    # Functions that set/get the nested struct
    lines.append("    function setVal(uint256 key, uint256 v) public {")
    lines.append("        store[key].val1 = v;")
    lines.append("    }")
    lines.append("")
    lines.append("    function getVal(uint256 key) public view returns (uint256) {")
    lines.append("        return store[key].val1;")
    lines.append("    }")
    lines.append("")

    # One function per nesting level that traverses the chain
    for i in range(1, size + 1):
        lines.append(f"    function readLevel{i}(uint256 key) public view returns (uint256) {{")
        # Build accessor chain: store[key].inner.inner…val
        chain = "store[key]"
        for _ in range(i - 1):
            chain += ".inner"
        chain += f".val{i}"
        lines.append(f"        return {chain};")
        lines.append("    }")
        lines.append("")

    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def _generate_wide_contract(size: int) -> str:
    """*size* state variables and *size* public functions.

    Exercises symbol-table construction and dispatch-table generation.
    """
    lines: list[str] = []
    lines.append(_SPDX)
    lines.append(_PRAGMA)
    lines.append("")
    lines.append("contract WideContract {")
    lines.append("")

    # State variables
    for i in range(1, size + 1):
        lines.append(f"    uint256 public var{i};")
    lines.append("")

    # Public setter/getter function pairs
    for i in range(1, size + 1):
        lines.append(f"    function set{i}(uint256 v) public {{")
        lines.append(f"        var{i} = v;")
        lines.append("    }")
        lines.append("")
        lines.append(f"    function get{i}() public view returns (uint256) {{")
        lines.append(f"        return var{i};")
        lines.append("    }")
        lines.append("")

    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def _generate_heavy_abi(size: int) -> str:
    """Functions with complex tuple/array parameters scaled by *size*.

    Exercises ABI encoding and decoding generation.
    """
    lines: list[str] = []
    lines.append(_SPDX)
    lines.append(_PRAGMA)
    lines.append("")
    lines.append("contract HeavyABI {")
    lines.append("")

    # Generate *size* struct types used as tuple parameters
    for i in range(1, size + 1):
        lines.append(f"    struct Param{i} {{")
        lines.append(f"        uint256 a{i};")
        lines.append(f"        address b{i};")
        lines.append(f"        bytes32 c{i};")
        lines.append(f"        uint256[] arr{i};")
        lines.append("    }")
        lines.append("")

    # Functions that accept and return these structs
    for i in range(1, size + 1):
        lines.append(
            f"    function process{i}(Param{i} calldata p, uint256[] calldata extra)"
            f" external pure returns (Param{i} memory, uint256) {{"
        )
        lines.append(f"        uint256 sum = p.a{i};")
        lines.append("        for (uint256 k = 0; k < extra.length; k++) {")
        lines.append("            sum += extra[k];")
        lines.append("        }")
        lines.append(f"        return (p, sum);")
        lines.append("    }")
        lines.append("")

    # Functions with nested array parameters
    for i in range(1, size + 1):
        lines.append(
            f"    function multiArray{i}(uint256[][] calldata matrix, bytes[] calldata data)"
            f" external pure returns (uint256) {{"
        )
        lines.append("        uint256 total = 0;")
        lines.append("        for (uint256 r = 0; r < matrix.length; r++) {")
        lines.append("            for (uint256 c = 0; c < matrix[r].length; c++) {")
        lines.append("                total += matrix[r][c];")
        lines.append("            }")
        lines.append("        }")
        lines.append("        total += data.length;")
        lines.append("        return total;")
        lines.append("    }")
        lines.append("")

    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def _generate_complex_control_flow(size: int) -> str:
    """Deeply nested conditionals, loops, and internal calls scaled by *size*.

    Exercises the control-flow graph builder and optimizer.
    """
    lines: list[str] = []
    lines.append(_SPDX)
    lines.append(_PRAGMA)
    lines.append("")
    lines.append("contract ComplexControlFlow {")
    lines.append("")

    # Internal helper functions that call each other
    for i in range(1, size + 1):
        lines.append(f"    function _helper{i}(uint256 x) internal pure returns (uint256) {{")
        lines.append("        uint256 result = x;")
        # Nested if/else chain
        for j in range(1, i + 1):
            indent = "        " + "    " * (j - 1)
            lines.append(f"{indent}if (result % {j + 1} == 0) {{")
            lines.append(f"{indent}    result = result / {j + 1} + {j};")
        # Close all the ifs
        for j in range(i, 0, -1):
            indent = "        " + "    " * (j - 1)
            lines.append(f"{indent}}}")
        lines.append("        return result;")
        lines.append("    }")
        lines.append("")

    # Public functions with nested loops and internal calls
    for i in range(1, size + 1):
        lines.append(f"    function compute{i}(uint256 n) public pure returns (uint256) {{")
        lines.append("        uint256 acc = 0;")
        # Nested for loops
        for j in range(1, min(i + 1, 4)):  # cap nesting at 3 to keep valid Solidity
            indent = "        " + "    " * (j - 1)
            lines.append(f"{indent}for (uint256 i{j} = 0; i{j} < n; i{j}++) {{")
        inner_indent = "        " + "    " * min(i, 3)
        lines.append(f"{inner_indent}acc += _helper{i}(acc);")
        for j in range(min(i, 3), 0, -1):
            indent = "        " + "    " * (j - 1)
            lines.append(f"{indent}}}")
        lines.append("        return acc;")
        lines.append("    }")
        lines.append("")

    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def _generate_heavy_storage(size: int) -> str:
    """Complex storage variables (mappings-of-mappings, dynamic arrays of structs).

    Exercises storage layout computation and slot assignment.
    """
    lines: list[str] = []
    lines.append(_SPDX)
    lines.append(_PRAGMA)
    lines.append("")
    lines.append("contract HeavyStorage {")
    lines.append("")

    # Struct types used in dynamic arrays
    for i in range(1, size + 1):
        lines.append(f"    struct Record{i} {{")
        lines.append(f"        uint256 id{i};")
        lines.append(f"        address owner{i};")
        lines.append(f"        bytes32 data{i};")
        lines.append("    }")
        lines.append("")

    # Mapping-of-mapping declarations (depth scales with index, capped at 4 to
    # avoid stack-too-deep in legacy codegen without optimizer)
    _MAX_DEPTH = 4
    for i in range(1, size + 1):
        depth = min(i, _MAX_DEPTH)
        inner = "uint256"
        for _ in range(depth):
            inner = f"mapping(address => {inner})"
        outer = f"mapping(uint256 => {inner})"
        lines.append(f"    {outer} public deepMap{i};")
    lines.append("")

    # Dynamic arrays of structs
    for i in range(1, size + 1):
        lines.append(f"    Record{i}[] public records{i};")
    lines.append("")

    # Accessor / mutator functions
    for i in range(1, size + 1):
        lines.append(f"    function addRecord{i}(uint256 id, address owner, bytes32 data) public {{")
        lines.append(f"        Record{i} storage r = records{i}.push();")
        lines.append(f"        r.id{i} = id;")
        lines.append(f"        r.owner{i} = owner;")
        lines.append(f"        r.data{i} = data;")
        lines.append("    }")
        lines.append("")
        lines.append(f"    function getRecordCount{i}() public view returns (uint256) {{")
        lines.append(f"        return records{i}.length;")
        lines.append("    }")
        lines.append("")

    # Mapping write/read helpers
    # deepMap{i} has depth min(i, _MAX_DEPTH): one uint256 key then depth address keys
    for i in range(1, size + 1):
        depth = min(i, _MAX_DEPTH)
        addr_params = ", ".join(f"address a{j}" for j in range(1, depth + 1))
        addr_keys = "".join(f"[a{j}]" for j in range(1, depth + 1))
        lines.append(f"    function setDeep{i}(uint256 k, {addr_params}, uint256 v) public {{")
        lines.append(f"        deepMap{i}[k]{addr_keys} = v;")
        lines.append("    }")
        lines.append("")
        lines.append(f"    function getDeep{i}(uint256 k, {addr_params}) public view returns (uint256) {{")
        lines.append(f"        return deepMap{i}[k]{addr_keys};")
        lines.append("    }")
        lines.append("")

    lines.append("}")
    lines.append("")
    return "\n".join(lines)
