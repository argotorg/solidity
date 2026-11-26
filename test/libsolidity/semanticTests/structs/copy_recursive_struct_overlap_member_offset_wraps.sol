contract C {
    struct Node { uint256 pad; Node[] children; uint256 v; }  // children at offset 1
    struct Wrapper { Node n; }

    function f() external returns (uint256) {
        // w.n based at the last slot, so the children member is at add(2**256-1, 1) = 0 (wrapped).
        Wrapper storage w;
        assembly { w.slot := sub(0, 1) }
        w.n.children.push();
        w.n.children[0].v = 7;
        w.n = w.n.children[0];
        return w.n.v;
    }
}
// ----
// f() -> 7
// gas irOptimized: 77380
// gas legacy: 81328
// gas legacyOptimized: 77411
// gas ssaCFGOptimized: 77411
