contract C
{
	function f() public payable {
		assert(msg.sender == block.coinbase);
		assert(block.difficulty == block.gaslimit);
		assert(block.prevrandao == block.gaslimit);
		assert(block.number == block.timestamp);
		assert(tx.gasprice == msg.value);
		assert(tx.origin == msg.sender);
		uint x = block.number;
		unchecked { x += 2; }
		assert(x > block.number);
		assert(block.timestamp > 10);
		assert(gasleft() > 100);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 8417: (93-109): Since the VM version paris, "difficulty" was replaced by "prevrandao", which now returns a random number based on the beacon chain.
// Warning 6328: (46-82): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x2298, block.gaslimit: 28100, block.number: 5853, block.prevrandao: 18446744073709551617, block.timestamp: 10450, msg.sender: 0x2297, msg.value: 32, tx.gasprice: 8365, tx.origin: 0x2e15 }
// Warning 6328: (86-128): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x2297, block.gaslimit: 11797, block.number: 28100, block.prevrandao: 18446744073709551617, block.timestamp: 30612, msg.sender: 0x2298, msg.value: 37, tx.gasprice: 32285, tx.origin: 0x20ad }
// Warning 6328: (132-174): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x2e15, block.gaslimit: 8365, block.number: 1142, block.prevrandao: 18446744073709551617, block.timestamp: 5853, msg.sender: 0x2e16, msg.value: 36, tx.gasprice: 10450, tx.origin: 0x7e1d }
// Warning 6328: (178-217): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x2e15, block.gaslimit: 8365, block.number: 8855, block.prevrandao: 18446744073709551617, block.timestamp: 8856, msg.sender: 0x2e16, msg.value: 36, tx.gasprice: 10450, tx.origin: 0x7e1d }
// Warning 6328: (221-253): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x2e15, block.gaslimit: 8365, block.number: 10451, block.prevrandao: 18446744073709551617, block.timestamp: 10450, msg.sender: 0x2e16, msg.value: 2, tx.gasprice: 1, tx.origin: 0x7794 }
// Warning 6328: (257-288): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x2297, block.gaslimit: 11797, block.number: 10451, block.prevrandao: 18446744073709551617, block.timestamp: 10450, msg.sender: 0x2298, msg.value: 19, tx.gasprice: 20, tx.origin: 0x2299 }
// Warning 6328: (341-365): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x20ad, block.gaslimit: 18446744073709551618, block.number: 115792089237316195423570985008687907853269984665640564039457584007913129639934, block.prevrandao: 18446744073709551617, block.timestamp: 32285, msg.sender: 0x20ae, msg.value: 23, tx.gasprice: 22, tx.origin: 0x16dd }
// Warning 6328: (369-397): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x7e1d, block.gaslimit: 8365, block.number: 115792089237316195423570985008687907853269984665640564039457584007913129639934, block.prevrandao: 18446744073709551617, block.timestamp: 0, msg.sender: 0x7e1e, msg.value: 36, tx.gasprice: 37, tx.origin: 0x16dd }
// Warning 6328: (401-424): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(){ block.coinbase: 0x7e1e, block.gaslimit: 5853, block.number: 115792089237316195423570985008687907853269984665640564039457584007913129639934, block.prevrandao: 18446744073709551617, block.timestamp: 5, msg.sender: 0x7e1d, msg.value: 36, tx.gasprice: 37, tx.origin: 0x7e1e }
