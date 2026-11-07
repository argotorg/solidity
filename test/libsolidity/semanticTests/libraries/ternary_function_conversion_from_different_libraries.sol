library L1 {
    function f(uint x) external pure returns (uint) {
        return x + 1;
    }
	    function g(uint y) public view returns (uint) {
        return y + (block.number / block.number);
    }
}

library L2 {
    function g(uint y) public view returns (uint) {
        return y + (block.number / block.number);
    }
}

contract C {
    function test(bool b, uint x) public view returns (uint) {
        return (b ? L1.f : L2.g)(x);
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// library: L1
// library: L2
// test(bool,uint256): true, 1 -> 2
// test(bool,uint256): false, 2 -> 3
