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
// EVMVersion: >=constantinople
// compileViaYul: true
// ----
// f(uint256): 98 -> 7
// gas irOptimized: 2066340
// gas ssaCFGOptimized: 2070164
// f(uint256): 99 -> 7
// gas irOptimized: 2070926
// gas ssaCFGOptimized: 2074789
// f(uint256): 169 -> FAILURE
// f(uint256): 170 -> FAILURE
