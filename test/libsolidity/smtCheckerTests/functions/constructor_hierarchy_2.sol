contract C { uint a; constructor(uint x) { a = x; } }
contract A is C { constructor() C(2) { assert(a == 2); } }
contract B is C { constructor() C(3) { assert(a == 3); } }
contract J is C { constructor() C(3) { assert(a == 4); } }
// ====
// SMTEngine: all
// ----
// Warning 6328: (211-225): CHC: Assertion violation happens here.\nCounterexample:\na = 3\n\nTransaction trace:\nJ.constructor()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
