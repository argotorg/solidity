// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;

contract A1 {
	uint128 stored;
	bool enabled;
	mapping(address => uint256) balances;
	uint256[] values;
	string label;

	function a(uint x) public pure {
		assert(x > 0);
	}
}

contract A2 {
	function a(uint x) public pure {
		assert(x > 0);
	}
}
