contract C {
    function() external[] arr;
    function() external f;

    constructor() {
        arr.push();
        arr.push();
        arr[1] = f;
        delete arr[1];
        assert(arr[1] == f); // should fail for now because function pointer comparisons are not supported
    }
}
// ----
// Warning 8364: (100-108): Assertion checker does not yet implement type function (function () external[] storage pointer) returns (function () external)
// Warning 8364: (120-128): Assertion checker does not yet implement type function (function () external[] storage pointer) returns (function () external)
// Warning 7229: (190-201): Assertion checker does not yet implement the type function () external for comparisons
// Warning 6368: (167-173): CHC: Out of bounds access happens here.\nCounterexample:\nf = 0\n\nTransaction trace:\nC.constructor()
// Warning 6368: (190-196): CHC: Out of bounds access happens here.\nCounterexample:\nf = 0\n\nTransaction trace:\nC.constructor()
// Warning 6328: (183-202): CHC: Assertion violation happens here.\nCounterexample:\narr = [15, 0], f = 0\n\nTransaction trace:\nC.constructor()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
