contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (uint256 sourceBalance, uint256 targetBalance, uint256 targetChildCount) {
        root.children.push();
        root.children[0].balance = 1;
        sourceBalance = root.children[0].balance;
        root = root.children[0];
        targetBalance = root.balance;
        targetChildCount = root.children.length;
    }
}
// ----
// f() -> 1, 1, 0
