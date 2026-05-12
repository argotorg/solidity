contract Small {
    uint public a;
    uint[] public b;
    function f1(uint x) public returns (uint) { a = x; b[uint8(msg.data[0])] = x; }
    fallback () external payable {}
}
// ====
// EVMVersion: =current
// optimize: true
// optimize-runs: 2
// bytecodeFormat: legacy
// ----
// creation:
//   codeDepositCost: 59200
//   executionCost: 109
//   totalCost: 59309
// external:
//   fallback: 134
//   a(): 2273
//   b(uint256): 4596
//   f1(uint256): 46730
