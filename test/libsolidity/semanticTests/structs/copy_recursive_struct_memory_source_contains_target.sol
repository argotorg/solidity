contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    function f() external pure returns (
        uint256 sourceBalance,
        uint256 sourceChildCount,
        uint256 targetBalance,
        uint256 targetChildCount,
        uint256 targetSecondChildBalance
    ) {
        Node memory root;
        root.balance = 42;
        root.children = new Node[](2);
        root.children[0].balance = 99;
        root.children[1].balance = 7;

        root.children[0] = root;

        sourceBalance = root.balance;
        sourceChildCount = root.children.length;
        targetBalance = root.children[0].balance;
        targetChildCount = root.children[0].children.length;
        targetSecondChildBalance = root.children[0].children[1].balance;
    }
}
// ----
// f() -> 42, 2, 42, 2, 7
