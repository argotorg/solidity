contract A {
    function f() public {}
}
contract C is A layout at uint32(this.f.selector) {}
// ----
// TypeError 1505: (68-91): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
