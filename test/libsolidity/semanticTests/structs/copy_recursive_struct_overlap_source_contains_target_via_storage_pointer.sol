contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    // `source` aliases an ancestor of the target through a storage pointer, so the
    // source contains the target. This direction is unsupported and its behavior is
    // undefined. Here it reverts.
    function sneakyAssign(Node storage source) internal {
        root.children[0] = source;
    }

    function f() external {
        root.children.push();
        root.children[0].balance = 11;
        sneakyAssign(root);
    }
}
// ----
// f() -> FAILURE
