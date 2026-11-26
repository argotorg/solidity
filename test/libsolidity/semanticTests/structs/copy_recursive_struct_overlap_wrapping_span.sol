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
        source.v = 7;
        source.children.push();
        source.children[0].v = 9;

        // w.n spans slots 2**256-1 and 0, wrapping around the end of storage and
        // overlapping source.
        Wrapper storage w;
        assembly { w.slot := sub(0, 1) }
        w.n = source;

        return (w.n.v, w.n.children.length, w.n.children[0].v);
    }
}
// ----
// f() -> 7, 1, 9
// gas irOptimized: 138684
// gas legacy: 143020
// gas legacyOptimized: 138749
// gas ssaCFGOptimized: 138661
