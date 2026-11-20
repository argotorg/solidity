contract C {
    struct Node {
        uint256 data;
        Node[] children;
    }

    mapping(uint256 => Node) trees;
    Node replacement;

    function f(uint256 n) external returns (uint256) {
        Node storage p = trees[n];
        for (uint256 i = 0; i < n; i++) {
            p.children.push();
            p = p.children[0];
        }
        replacement.data = 7;
        trees[n] = replacement;
        return trees[n].data;
    }
}
// ====
// compileViaYul: false
// ----
// f(uint256): 36 -> 7
// gas legacy: 839505
// gas legacyOptimized: 793598
// f(uint256): 37 -> 7
// gas legacy: 845292
// gas legacyOptimized: 798140
// f(uint256): 92 -> FAILURE
// f(uint256): 93 -> FAILURE
