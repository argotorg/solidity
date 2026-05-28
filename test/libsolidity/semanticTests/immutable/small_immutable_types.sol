contract C {
	uint8 public immutable a;
	address public immutable b;

	constructor() {
		a = 0xff;
		b = address(0xdEaD);
	}

	function get() public view returns (uint8, address) {
		return (a, b);
	}
}
// ----
// a() -> 0xff
// b() -> 0xdead
// get() -> 0xff, 0xdead
