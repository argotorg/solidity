type MyInt is int16;

contract C {
	uint8 public immutable a;
	address public immutable b;
	MyInt public immutable c;
	int8 public immutable d;

	constructor() {
		a = 0xff;
		b = address(0xdEaD);
		c = MyInt.wrap(-1);
		d = -2;
	}

	function get() public view returns (uint8, address, MyInt, int8) {
		return (a, b, c, d);
	}
}
// ----
// a() -> 0xff
// b() -> 0xdead
// c() -> -1
// d() -> -2
// get() -> 0xff, 0xdead, -1, -2
