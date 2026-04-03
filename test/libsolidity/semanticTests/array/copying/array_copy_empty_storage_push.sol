contract C {
    int8[][] array;

    function s() public {
        array.push() = array.push();
    }
    function getLength() public view returns (uint256) {
        return array.length;
    }
    function getInnerLength(uint256 i) public view returns (uint256) {
        return array[i].length;
    }
}
// ----
// getLength() -> 0
// s() ->
// getLength() -> 2
// getInnerLength(uint256): 0 -> 0
// getInnerLength(uint256): 1 -> 0
// s() ->
// getLength() -> 4
