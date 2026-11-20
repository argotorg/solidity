contract C {
    struct Node {
        Node[] children;
        uint256 v;
    }
    struct Wrapper {
        Node n;
    }

    function f() external {
        // target (w.n) occupies slots 2**256-2 and 2**256-1.
        Wrapper storage w;
        assembly { w.slot := sub(0, 2) }
        w.n.children.push();
        w.n.children[0].children.push();

        // Source contains the target. The guard only handles the opposite direction, so this
        // falls through to a direct copy whose behavior is undefined. Here it reverts.
        w.n.children[0] = w.n;
    }
}
// ----
// f() -> FAILURE
