contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    // The pushed value contains the target array, so the push fails.
    function sneakyPush(Node[] storage array, Node storage node) internal {
        array.push(node);
    }

    function f() external {
        root.children.push();
        root.children[0].balance = 11;
        sneakyPush(root.children, root);
    }
}
// ----
// f() -> FAILURE
