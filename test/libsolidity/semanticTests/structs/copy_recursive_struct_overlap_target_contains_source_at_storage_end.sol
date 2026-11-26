contract C {
    struct Node {
        Node[] children;
        uint256 v;
    }
    struct Wrapper {
        Node n;
    }

    function f() external returns (uint256, uint256, uint256) {
        // target (w.n) occupies slots 2**256-2 and 2**256-1.
        Wrapper storage w;
        assembly { w.slot := sub(0, 2) }
        w.n.v = 1;
        w.n.children.push();
        w.n.children[0].v = 7;
        w.n.children[0].children.push();
        w.n.children[0].children[0].v = 9;

        // Target contains the source, the runtime guard must snapshot.
        w.n = w.n.children[0];

        return (w.n.v, w.n.children.length, w.n.children[0].v);
    }
}
// ----
// f() -> 7, 1, 9
// gas irOptimized: 111368
// gas legacy: 115880
// gas legacyOptimized: 111122
// gas ssaCFGOptimized: 111489
