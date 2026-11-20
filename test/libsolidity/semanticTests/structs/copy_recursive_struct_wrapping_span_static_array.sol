contract C {
    struct Node {
        Node[] children;
        uint256 v;
    }
    struct Wrapper {
        Node[2] pair;
    }

    function f() external returns (uint256, uint256) {
        // pair spans four slots from 2**256-1, so pair[0] wraps around the end of storage.
        Wrapper storage w;
        assembly { w.slot := sub(0, 1) }
        w.pair[1].v = 5;
        w.pair[1].children.push();
        w.pair[1].children[0].v = 8;

        w.pair[0] = w.pair[1];

        return (w.pair[0].v, w.pair[0].children[0].v);
    }
}
// ----
// f() -> 5, 8
// gas irOptimized: 160260
// gas legacy: 162889
// gas legacyOptimized: 160304
// gas ssaCFGOptimized: 160375
