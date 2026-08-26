contract C {
    uint256[2**255][] data;

    function fill() public {
        data.push();
        data.push();
        data[0][0] = 111;
        data[1][0] = 222;
    }

    function get(uint256 idx) public view returns (uint256) {
        return data[idx][0];
    }

    function clear() public {
        delete data;
    }

    function length() public view returns (uint256) {
        return data.length;
    }
}
// ----
// fill() ->
// get(uint256): 0 -> 111
// get(uint256): 1 -> 222
// length() -> 2
// clear() -> FAILURE, hex"4e487b71", 0x11
// get(uint256): 0 -> 111
// get(uint256): 1 -> 222
// length() -> 2
