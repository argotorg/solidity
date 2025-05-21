contract B {
    function fail() pure public { assert(false); }
}

contract A {
    function safe() pure public { }
}
// ====
// SMTContract: A
// SMTEngine: chc
// ----
