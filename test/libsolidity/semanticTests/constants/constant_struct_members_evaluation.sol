pragma abicoder v2;

struct S {
    uint value;
}

library L {
    function getValue(S memory s) internal pure returns(uint) {
        return s.value;
    }

    function getValueExternal(S memory s) external pure returns(uint) {
        return s.value;
    }

    function getValuePublic(S memory s) public pure returns(uint) {
        return s.value;
    }
}

using L for S;

contract C {
    uint constant public structValue = S(11).value;

    function testAttachedFunction() pure public returns(uint, uint) {
        return (S(3).getValue(), S(5).value);
    }

    function testAttachedExternalFunction() pure public returns(uint) {
        return S(7).getValueExternal();
    }

    function testAttachedPublicFunction() pure public returns(uint) {
        return S(9).getValuePublic();
    }
}
// ----
// library: L
// testAttachedFunction() -> 3, 5
// testAttachedExternalFunction() -> 7
// testAttachedPublicFunction() -> 9
// structValue() -> 11
