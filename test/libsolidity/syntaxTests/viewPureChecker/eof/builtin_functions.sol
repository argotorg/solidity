contract C {
    function f() public {
        payable(this).transfer(1);
        require(payable(this).send(2));
        (bool success,) = address(this).delegatecall("");
        require(success);
        (success,) = address(this).call("");
        require(success);
    }
    function g() pure public {
        bytes32 x = keccak256("abc");
        bytes32 y = sha256("abc");
        address z = ecrecover(bytes32(uint256(1)), uint8(2), bytes32(uint256(3)), bytes32(uint256(4)));
        require(true);
        assert(true);
        x; y; z;
    }
    receive() payable external {}
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// Warning 9207: (47-69): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 9207: (90-108): 'send' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
