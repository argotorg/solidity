contract C {
    struct Node {
        Node[] children;
        uint256 v;
    }
    struct Wrapper {
        Node n;
    }

    // source occupies slots 0 and 1.
    Node source;

    function f() external returns (uint256, uint256, uint256) {
        source.v = 1;
        source.children.push();
        source.children[0].v = 7;

        // target (w.n) occupies slots 2**256-4 and 2**256-3, disjoint from source.
        Wrapper storage w;
        assembly { w.slot := sub(0, 4) }
        w.n = source;

        return (w.n.v, w.n.children.length, w.n.children[0].v);
    }
}
// ----
// f() -> 1, 1, 7
// gas irOptimized: 160240
// gas legacy: 162839
// gas legacyOptimized: 160331
// gas ssaCFGOptimized: 160221
