{
    // NOTE: All EVM instruction names are reserved identifiers in Yul.
    // NOTE: We don't provide builtins corresponding to these instructions.
    function dup1(dup2) -> dup3 {}
    let dup4
}
// ----
// DeclarationError 5017: (154-184): The identifier "dup1" is reserved and can not be used.
// DeclarationError 5017: (168-172): The identifier "dup2" is reserved and can not be used.
// DeclarationError 5017: (177-181): The identifier "dup3" is reserved and can not be used.
// DeclarationError 5017: (193-197): The identifier "dup4" is reserved and can not be used.
