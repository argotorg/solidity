contract C {
    address owner;
    modifier onlyOwner {
        if (msg.sender == owner) _;
    }
    function g() public onlyOwner {
    }
    function f(uint x) public {
        if (x > 0) g();
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
