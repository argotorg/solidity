contract Creator {
    uint256 public r;
    address public ch;

    constructor(address[3] memory s, uint256 x) {
        r = x;
        ch = s[2];
    }
}
// ----
// constructor(): 1, 2, 3, 4 ->
// gas irOptimized: 103767
// gas irOptimized code: 21800
// gas legacy: 115185
// gas legacy code: 59000
// gas legacyOptimized: 104565
// gas legacyOptimized code: 22600
// r() -> 4
// ch() -> 3
