// TODO: Recreate this test when eofcreate will be allowed in inline assembly.
contract D {
    uint256 x;

    constructor() {
        x = 7;
    }

    function f() public view returns (uint256) {
        return x;
    }
}


contract C {
    function test() public returns (uint256) {
        bytes memory c = type(D).creationCode;
        D d;
        assembly {
            d := create(0, add(c, 0x20), mload(c))
        }
        return d.f();
    }
}
// ====
// bytecodeFormat: legacy
// ----
// test() -> 7
// gas legacy: 76647
// gas legacy code: 24200
