struct Item {
	uint x;
	uint y;
}

contract D {
	Item[] public items;

	function test() public {
		delete items;
		items.push(Item(42, 43));
		Item memory item = this.items(0);
		assert(item.x == 42); // should hold
		assert(item.y == 43); // should hold
		assert(item.y == 0); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (257-276): CHC: Assertion violation happens here.\nCounterexample:\nitems = [{x: 42, y: 43}]\nitem = {x: 42, y: 43}\n\nTransaction trace:\nD.constructor()\nState: items = []\nD.test()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
