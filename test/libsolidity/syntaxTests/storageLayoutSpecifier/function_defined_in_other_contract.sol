contract A {
    function f() external pure {}
}

contract C layout at A.f { }
// ----
// TypeError 1763: (71-74): The base slot of the storage layout must evaluate to an integer.
