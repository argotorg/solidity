contract C
{
	function f(uint prevrandao) public view {
		assert(block.prevrandao == prevrandao); // should fail
		assert(block.difficulty == prevrandao); // should fail
		assert(block.difficulty == block.prevrandao); // should hold
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 8417: (122-138): Since the VM version paris, "difficulty" was replaced by "prevrandao", which now returns a random number based on the beacon chain.
// Warning 8417: (179-195): Since the VM version paris, "difficulty" was replaced by "prevrandao", which now returns a random number based on the beacon chain.
// Warning 6328: (58-96): CHC: Assertion violation happens here.\nCounterexample:\n\nprevrandao = 0\n\nTransaction trace:\nC.constructor()\nC.f(0){ block.prevrandao: 18446744073709551617 }
// Warning 6328: (115-153): CHC: Assertion violation happens here.\nCounterexample:\n\nprevrandao = 0\n\nTransaction trace:\nC.constructor()\nC.f(0){ block.prevrandao: 18446744073709551617 }
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
