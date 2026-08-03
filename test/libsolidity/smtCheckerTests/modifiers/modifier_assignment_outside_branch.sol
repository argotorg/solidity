contract C
{
    uint x;
    address owner;

	modifier onlyOwner {
        if (msg.sender == owner) _;
    }

    function f() public onlyOwner {
    }

    function g(uint y) public {
        y = 1;
        if (y > x) f();
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
