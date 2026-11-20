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

        // Source contains the target, reached through a conditional index. This
        // source-contains-target direction is unsupported and its behavior is undefined.
        // Here it reverts.
        root.children[flag() ? 1 : 0].children[flag() ? 1 : 0] = root.children[flag() ? 1 : 0];
    }

    function flag() internal pure returns (bool) { return true; }
}
// ----
// f() -> FAILURE
