contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external {
        root.children.push();
        root.children.push();
        root.children[1].children.push();
        root.children[1].children.push();

        // Source contains the target, reached through an arithmetic index. This
        // source-contains-target direction is unsupported and its behavior is undefined.
        // Here it reverts.
        root.children[zero() + 1].children[zero() + 1] = root.children[zero() + 1];
    }

    function zero() internal pure returns (uint256) { return 0; }
}
// ----
// f() -> FAILURE
