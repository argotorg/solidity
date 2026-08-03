contract test {
    mapping (address => function() internal returns (uint)) a;
    mapping (address => function() external) b;
    mapping (address => function() external[]) c;
    function() external[] d;
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
