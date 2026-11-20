contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (uint256 sourceBalance, uint256 targetBalance, uint256 targetChildCount) {
        root.children.push();
        root.children[0].children.push();
        root.children[0].balance = 11;
        root.children[0].children[0].balance = 22;
        sourceBalance = root.children[0].children[0].balance;

        // Target (root.children[0]) contains the source
        // (root.children[0].children[0]). Same overlap direction as the
        // top-level case, one level below the root.
        root.children[0] = root.children[0].children[0];

        targetBalance = root.children[0].balance;
        targetChildCount = root.children[0].children.length;
    }
}
// ----
// f() -> 22, 22, 0
