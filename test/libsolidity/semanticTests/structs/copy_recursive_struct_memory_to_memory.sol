contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    function f() external pure returns (uint256 targetBalance, uint256 targetChildCount) {
        Node memory root;
        root.balance = 11;
        root.children = new Node[](1);
        root.children[0].balance = 22;

        root = root.children[0];

        targetBalance = root.balance;
        targetChildCount = root.children.length;
    }
}
// ----
// f() -> 22, 0
