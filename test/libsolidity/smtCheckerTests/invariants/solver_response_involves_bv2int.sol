// Taken from issue #15770
contract c {
    function f(uint len) public pure returns (bytes memory) {
        bytes memory x = new bytes(len);
        for (uint i = 0; i < len; i++) {
            x[i] = bytes1(uint8(i));
        }
        return x;
    }
}
// ====
// SMTEngine: chc
// SMTIgnoreInv: no
// SMTSolvers: z3
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
