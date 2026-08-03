contract C {
  function g(bool b) public {}
  function f(bool b) public returns (bytes memory txt) {
    if (0==1)
      try this.g(b) {}
      catch (bytes memory s) {
        txt = s;
      }
  }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (109-113): BMC: Condition is always false.
