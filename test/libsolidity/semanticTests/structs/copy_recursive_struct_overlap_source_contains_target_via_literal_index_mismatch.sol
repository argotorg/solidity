contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node[] a;

    // a[0] and a[0x0] are the same location spelled differently, so the source contains
    // the target. This direction is unsupported and its behavior is undefined. Here it reverts.
    function f() external {
        a.push();
        a[0].children.push();
        a[0].children[0] = a[0x0];
    }
}
// ----
// f() -> FAILURE
