// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;

contract test {
	uint[] arr;
	function f(address payable a, uint x) public {
		require(x >= 0);
		--x;
		x + type(uint).max;
		2 / x;
		(bool success, ) = a.call{value: x}("");
		require(success);
		assert(x > 0);
		arr.pop();
		arr[x];
	}
}
