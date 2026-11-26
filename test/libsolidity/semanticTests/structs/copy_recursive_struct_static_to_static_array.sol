contract C {
    struct Node {
        Node[] children;
        uint256 v;
    }

    Node[2] a;
    Node[2] b;

    function f() external returns (uint256, uint256, uint256) {
        b[0].v = 1;
        b[1].children.push();
        b[1].children[0].v = 7;

        a = b;

        return (a[0].v, a[1].children.length, a[1].children[0].v);
    }
}
// ----
// f() -> 1, 1, 7
// gas irOptimized: 168993
// gas legacy: 172902
// gas legacyOptimized: 168987
// gas ssaCFGOptimized: 169069
