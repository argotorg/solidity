contract C {
    type T is address;
    T[] arr;

    function p() public {
        arr.push(T.wrap(address(42)));
    }

    function inv(uint i) external view {
        require(i < arr.length);
        assert(T.unwrap(arr[i]) == address(42)); // should hold
    }
}
// ====
// SMTIgnoreOS: macos
// ----
// Warning 6328: (204-243): CHC: Assertion violation might happen here.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (204-243): BMC: Assertion violation happens here.
