contract B {
    constructor() { fail(); }

    function fail() pure internal { assert(false); }
}

contract A {
    function safe() pure public { }
}
// ====
// SMTContract: A
// SMTEngine: chc
// ----
