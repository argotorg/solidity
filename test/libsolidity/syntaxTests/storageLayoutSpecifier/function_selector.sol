contract A {
    function f() public {}
}
contract C is A layout at uint32(this.f.selector) {}
// ----
// TypeError 6396: (68-91): The base slot of the storage layout must evaluate to a rational number.
