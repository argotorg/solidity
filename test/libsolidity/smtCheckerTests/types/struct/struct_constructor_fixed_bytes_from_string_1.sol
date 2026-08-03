contract C {
  struct S {
    int a;
    bytes5 b;
  }
  function f() public pure {
    assert(S({a:2, b:""}).b == bytes5(0)); // should hold
    assert(S({a:2, b:""}).a == 0); // should fail
  }
}
// ----
// Warning 6328: (146-175): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
