type U is uint;
using {div as /} for U global;

function div(U x, U y) pure returns (U) {
    return U.wrap(U.unwrap(x) / U.unwrap(y)); // detects division by zero
}

contract C {
    function f(U x, U y) public pure returns (U) {
        return x / y; // reports division by zero in the implementation
    }
}
// ====
// SMTEngine: all
// ----
// Warning 4281: (108-133): CHC: Division by zero happens here.\nCounterexample:\n\nx = 0\ny = 0\n = 0\n\nTransaction trace:\nC.constructor()\nC.f(0, 0)\n    div(0, 0) -- internal call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
