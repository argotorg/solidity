contract C {
    struct S { uint x; }
    S s;
    function e() pure public {
        assembly { mstore(keccak256(0, 20), mul(s.slot, 2)) }
    }
    function f() pure public {
        uint x;
        assembly { x := 7 }
    }
    function g() view public {
        assembly { for {} 1 { pop(sload(0)) } { } pop(calldataload(0)) }
    }
    function h() view public {
        assembly { function g() { pop(blockhash(20)) } }
    }
    function i() public {
        assembly { pop(extcall(0, 1, 2, 3)) }
    }
    function k() public view {
        assembly { pop(balance(0)) }
    }
    function l() public pure {
        assembly { pop(calldataload(0)) }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
