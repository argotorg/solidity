contract B {
    uint immutable x = 1;
    function f() public pure returns (uint) {
        return x;
    }
}

contract C {
    address immutable a = address(1);
    bool immutable b = true;
    bytes32 immutable c = keccak256("c");

    function f() public pure returns (address, bool, bytes32) {
        return (a, b, c);
    }

    function g() public pure returns (address) {
        return C.a;
    }
}
// ----
