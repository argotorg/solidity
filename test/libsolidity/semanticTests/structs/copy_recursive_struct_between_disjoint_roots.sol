contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root1;
    Node root2;

    function f() external returns (uint256 sourceBalance, uint256 targetBalance, uint256 targetChildCount) {
        root2.children.push();
        root2.children[0].balance = 1;

        sourceBalance = root2.children[0].balance;

        root1 = root2.children[0];

        targetBalance = root1.balance;
        targetChildCount = root1.children.length;
    }
}
// ----
// f() -> 1, 1, 0
