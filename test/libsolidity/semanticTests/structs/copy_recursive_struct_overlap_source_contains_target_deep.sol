contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    // The source contains the target two levels down, so the copy fails.
    function sneakyAssign(Node storage source) internal {
        root.children[0].children[0] = source;
    }

    function f() external {
        root.children.push();
        root.children[0].children.push();
        root.children[0].children[0].balance = 11;
        sneakyAssign(root);
    }
}
// ----
// f() -> FAILURE
