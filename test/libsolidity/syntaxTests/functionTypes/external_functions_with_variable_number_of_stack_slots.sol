contract C {
    function f (address) payable external returns (bool) {
        this.f{value: 42}.address;
    }
}
// ----
// Warning 6321: (64-68): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
