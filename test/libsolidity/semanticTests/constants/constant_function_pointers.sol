contract C {
    function add1(uint256 x) internal pure returns (uint256) { return x + 1; }
    function mul2(uint256 x) internal pure returns (uint256) { return x * 2; }
    function sub1(uint256 x) internal pure returns (uint256) { return x - 1; }

    function(uint256) internal pure returns (uint256)[3] constant ops = [add1, mul2, sub1];

    function execAdd1(uint256 val) public pure returns (uint256) { return ops[0](val); }
    function execMul2(uint256 val) public pure returns (uint256) { return ops[1](val); }
    function execSub1(uint256 val) public pure returns (uint256) { return ops[2](val); }
    function execDynamic(uint256 op, uint256 val) public pure returns (uint256) { return ops[op](val); }
}
// ====
// compileViaYul: true
// ----
// execAdd1(uint256): 10 -> 11
// execMul2(uint256): 10 -> 20
// execSub1(uint256): 10 -> 9
// execDynamic(uint256,uint256): 0, 100 -> 101
// execDynamic(uint256,uint256): 1, 100 -> 200
// execDynamic(uint256,uint256): 2, 100 -> 99
