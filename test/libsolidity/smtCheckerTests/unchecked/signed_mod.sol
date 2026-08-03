contract C {
    function f(int a, int b) public pure returns (int) {
        return a % b; // can div by 0
    }
    function g(bool _check) public pure returns (int) {
        int x = type(int).min;
        if (_check) {
            return x / -1; // can overflow
        } else {
            unchecked { return x / -1; } // overflow not reported
        }
    }
}
// ====
// SMTEngine: all
// ----
// Warning 4281: (85-90): CHC: Division by zero happens here.\nCounterexample:\n\na = 0\nb = 0\n = 0\n\nTransaction trace:\nC.constructor()\nC.f(0, 0)
// Warning 4984: (242-248): CHC: Overflow (resulting value larger than 2**255 - 1) happens here.\nCounterexample:\n\n_check = true\n = 0\nx = (- 57896044618658097711785492504343953926634992332820282019728792003956564819968)\n\nTransaction trace:\nC.constructor()\nC.g(true)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
