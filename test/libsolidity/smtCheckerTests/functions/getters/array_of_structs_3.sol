struct Item {
	uint x;
	uint y;
	uint[] arr;
}

contract D {
	Item[] public items;

	function test() public {
		delete items;
		uint[] memory tmp = new uint[](1);
		items.push(Item(42, 43, tmp));
		Item memory item = this.items(0);
		assert(item.x == 42); // should hold
		assert(item.y == 43); // should hold
		assert(item.y == 0); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (312-331): CHC: Assertion violation happens here.\nCounterexample:\nitems = [{x: 42, y: 43, arr: [0]}]\ntmp = [0]\nitem = {x: 42, y: 43, arr: [0]}\n\nTransaction trace:\nD.constructor()\nState: items = []\nD.test()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
