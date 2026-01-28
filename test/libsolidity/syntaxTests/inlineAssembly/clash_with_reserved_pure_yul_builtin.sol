contract C {
    function f() public view {
        assembly {
            // NOTE: These are builtins but only in pure Yul, not inline assembly.
            // NOTE: Names of these builtins are also reserved identifiers.
            function loadimmutable(setimmutable) -> datasize {}
            let dataoffset
        }
    }
}
// ----
// DeclarationError 5017: (234-285): The identifier "loadimmutable" is reserved and can not be used.
// DeclarationError 5017: (257-269): The identifier "setimmutable" is reserved and can not be used.
// DeclarationError 5017: (274-282): The identifier "datasize" is reserved and can not be used.
// DeclarationError 5017: (302-312): The identifier "dataoffset" is reserved and can not be used.
