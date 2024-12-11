contract D { constructor() payable {} }
contract C {
	uint public x;
	constructor() payable {}
	function f(uint amount) public returns (bool) {
		x++;
		return address((new D){value: amount, salt: bytes32(x)}()) != address(0);
	}
	function stack(uint depth) public payable returns (bool) {
		if (depth > 0)
			return this.stack(depth - 1);
		else
			return f(0);
	}
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// constructor(), 20 wei
// gas irOptimized: 61548
// gas irOptimized code: 104600
// gas legacy: 70147
// gas legacy code: 215400
// gas legacyOptimized: 61715
// gas legacyOptimized code: 106800
// f(uint256): 20 -> true
// x() -> 1
// f(uint256): 20 -> FAILURE
// x() -> 1
// stack(uint256): 1023 -> FAILURE
// gas irOptimized: 252410
// gas legacy: 477722
// gas legacyOptimized: 299567
// x() -> 1
// stack(uint256): 10 -> true
// x() -> 2
