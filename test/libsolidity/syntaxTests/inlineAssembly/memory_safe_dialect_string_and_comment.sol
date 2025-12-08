function f() pure {
    /// @solidity memory-safe-assembly
    assembly "evmasm" ("memory-safe") {
    }
}
// ----
// Warning 8544: (63-104): Inline assembly marked as memory safe using both a NatSpec tag and an assembly block annotation. If you are not concerned with backwards compatibility, only use the assembly block annotation, otherwise only use the NatSpec tag.
// Warning 2424: (63-104): Natspec memory-safe-assembly special comment for inline assembly is deprecated and scheduled for removal. Use the memory-safe block annotation instead.
