contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (
        uint256 targetLength,
        uint256 firstBalance,
        uint256 lastBalance,
        uint256 firstChildCount,
        uint256 lastChildCount
    ) {
        root.children.push();
        root.children[0].balance = 5;

        root.children.push(root.children[0]);

        targetLength = root.children.length;
        firstBalance = root.children[0].balance;
        lastBalance = root.children[1].balance;
        firstChildCount = root.children[0].children.length;
        lastChildCount = root.children[1].children.length;
    }
}
// ----
// f() -> 2, 5, 5, 0, 0
