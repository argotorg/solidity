contract Other {
	C c;
	function h(bool b) public {
		if (b)
			c.setOwner(address(0));
	}
}
contract C {
	address owner;
	function setOwner(address _owner) public {
		owner = _owner;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
