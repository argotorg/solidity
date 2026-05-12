contract C {
    uint x;
    function setX(uint y) public {
        x = y;
    }
    function resetX() public {
        x = 0;
    }
    function readX() public view returns(uint) {
        return x;
    }
}
// ====
// EVMVersion: =current
// optimize: true
// optimize-yul: true
// bytecodeFormat: legacy
// ----
// creation:
//   codeDepositCost: 26600
//   executionCost: 79
//   totalCost: 26679
// external:
//   readX(): 2302
//   resetX(): 5131
//   setX(uint256): 22326
