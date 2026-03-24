contract C {
    function f() public {
        erc7201.gas();
    }
}
// ----
// TypeError 9582: (47-58): Member "gas" not found or not visible after argument-dependent lookup in function (string memory) pure returns (uint256).
