contract C {
    struct Node {
        Node[] children;
        uint256 v;
    }
    Node root;

    function f() external {
        root.children.push();
        root.children[0].v = 9;
        // children.length = 2**255 makes the overlap check's mul(length, 2) wrap to 0.
        assembly { sstore(root.slot, 0x8000000000000000000000000000000000000000000000000000000000000000) }
        root = root.children[0];
    }
}
// ----
// f() -> FAILURE, hex"4e487b71", 0x11
