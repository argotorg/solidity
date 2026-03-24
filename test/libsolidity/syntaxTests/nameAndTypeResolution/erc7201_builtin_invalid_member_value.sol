contract C {
    function f() public {
        erc7201.value();
    }
}
// ----
// TypeError 8820: (47-60): Member "value" is only available for payable functions.
