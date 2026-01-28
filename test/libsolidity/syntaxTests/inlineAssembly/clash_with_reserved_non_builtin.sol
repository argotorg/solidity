contract C {
    function f() public pure {
        assembly {
            // NOTE: All EVM instruction names are reserved identifiers in Yul.
            // NOTE: We don't provide builtins corresponding to these instructions.
            function dup1(dup2) -> dup3 {}
            let dup4
        }
    }
}
// ----
// DeclarationError 5017: (239-269): The identifier "dup1" is reserved and can not be used.
// DeclarationError 5017: (253-257): The identifier "dup2" is reserved and can not be used.
// DeclarationError 5017: (262-266): The identifier "dup3" is reserved and can not be used.
// DeclarationError 5017: (286-290): The identifier "dup4" is reserved and can not be used.
