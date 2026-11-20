contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (uint256 targetBalance, uint256 targetChildCount, uint256 firstChildBalance) {
        root.children.push();
        root.children[0].balance = 99;
        root.balance = 42;

        root = root;

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildBalance = root.children[0].balance;
    }
}
// ----
// f() -> 42, 1, 99
