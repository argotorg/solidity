type U8 is uint8;
using {add as +} for U8 global;

function add(U8 x, U8 y) pure returns (U8) {
    return U8.wrap(U8.unwrap(x) + U8.unwrap(y)); // overflow detected
}

contract C {
    U8 x = U8.wrap(255);

    function inc() public {
        x = x + U8.wrap(1);
    }

    function check() view public {
        U8 y = x;
        assert(U8.unwrap(y) < 256);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (115-142): CHC: Overflow (resulting value larger than 255) happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.inc()\n    add(255, 1) -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
