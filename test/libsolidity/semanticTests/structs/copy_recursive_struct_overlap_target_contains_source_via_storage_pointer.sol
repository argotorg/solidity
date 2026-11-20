contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (uint256 sourceBalance, uint256 targetBalance, uint256 targetChildCount) {
        root.children.push();
        root.children[0].balance = 42;
        Node storage firstChild = root.children[0];
        sourceBalance = firstChild.balance;
        root = firstChild;
        targetBalance = root.balance;
        targetChildCount = root.children.length;
    }
}
// ----
// f() -> 42, 42, 0
