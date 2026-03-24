contract C {
    uint256[] constant DATA = [uint256(10), 20, 30, 40, 50];

    function len() public pure returns (uint256) {
        return DATA.length;
    }
    function get(uint256 i) public pure returns (uint256) {
        return DATA[i];
    }
    function sliceIdx(uint256 s, uint256 e, uint256 i) public pure returns (uint256) {
        return DATA[s:e][i];
    }
    function sliceStartOnly(uint256 s, uint256 i) public pure returns (uint256) {
        return DATA[s:][i];
    }
    function sliceEndOnly(uint256 e, uint256 i) public pure returns (uint256) {
        return DATA[:e][i];
    }
    function nestedSlice(uint256 s, uint256 e, uint256 ss, uint256 ee, uint256 i) public pure returns (uint256) {
        return DATA[s:e][ss:ee][i];
    }
}
// ====
// compileViaYul: true
// ----
// len() -> 5
// get(uint256): 0 -> 10
// get(uint256): 4 -> 50
// get(uint256): 5 -> FAILURE, hex"4e487b71", 0x32
// sliceIdx(uint256,uint256,uint256): 1, 4, 0 -> 20
// sliceIdx(uint256,uint256,uint256): 1, 4, 2 -> 40
// sliceIdx(uint256,uint256,uint256): 0, 5, 4 -> 50
// sliceIdx(uint256,uint256,uint256): 2, 2, 0 -> FAILURE, hex"4e487b71", 0x32
// sliceIdx(uint256,uint256,uint256): 0, 6, 0 -> FAILURE
// sliceIdx(uint256,uint256,uint256): 3, 2, 0 -> FAILURE
// sliceStartOnly(uint256,uint256): 2, 0 -> 30
// sliceStartOnly(uint256,uint256): 2, 2 -> 50
// sliceStartOnly(uint256,uint256): 6, 0 -> FAILURE
// sliceEndOnly(uint256,uint256): 3, 0 -> 10
// sliceEndOnly(uint256,uint256): 3, 2 -> 30
// sliceEndOnly(uint256,uint256): 6, 0 -> FAILURE
// nestedSlice(uint256,uint256,uint256,uint256,uint256): 1, 4, 1, 2, 0 -> 30
