contract C {
    type T is address;
    T[] arr;

    function p() public {
        arr.push(T.wrap(address(42)));
    }

    function inv2() external view {
        if (arr.length > 0) {
            assert(T.unwrap(arr[0]) == address(0)); // should fail
        }
    }
}
// ----
// Warning 6328: (200-238): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.p()\nC.inv2()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
