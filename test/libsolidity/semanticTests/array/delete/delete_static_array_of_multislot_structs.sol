contract C {
    struct S { uint256 a; uint256 b; }
    S[5] data;

    function fill() public {
        data[0] = S(1, 2);
        data[4] = S(3, 4);
    }

    function get(uint256 i) public view returns (uint256, uint256) {
        return (data[i].a, data[i].b);
    }

    function clear() public { delete data; }
}
// ----
// fill() ->
// gas irOptimized: 110009
// gas legacy: 110395
// gas legacyOptimized: 110037
// gas ssaCFGOptimized: 110008
// get(uint256): 0 -> 1, 2
// get(uint256): 4 -> 3, 4
// clear() ->
// get(uint256): 0 -> 0, 0
// get(uint256): 4 -> 0, 0
