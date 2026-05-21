interface I {
    function f() external;
}

abstract contract A {
    function g() public virtual;
}

contract C is A, I {
    function f() external override {}
    function g() public override {}
}
// ----
// C.contract.name: C
// C.creation.environment: create
// C.runtime.environment: call
