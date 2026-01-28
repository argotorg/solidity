{
    function a() {}
    function f() { mstore(0, 1) }
    function g() { sstore(0, 1) }
    function h() { let x := balance(0x0) }
    function i() { let z := mload(0) }
}
// ====
// dialect: evm
// ----
