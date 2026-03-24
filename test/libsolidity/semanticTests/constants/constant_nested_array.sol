contract C {
    uint256[2][3] constant MATRIX = [[uint256(1), 2], [uint256(3), 4], [uint256(5), 6]];

    function get(uint256 i, uint256 j) public pure returns (uint256) {
        return MATRIX[i][j];
    }
}
// ====
// compileViaYul: true
// ----
// get(uint256,uint256): 0, 0 -> 1
// get(uint256,uint256): 0, 1 -> 2
// get(uint256,uint256): 1, 0 -> 3
// get(uint256,uint256): 1, 1 -> 4
// get(uint256,uint256): 2, 0 -> 5
// get(uint256,uint256): 2, 1 -> 6
