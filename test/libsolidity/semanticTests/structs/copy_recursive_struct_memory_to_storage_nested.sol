contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (
        uint256 targetBalance,
        uint256 targetChildCount,
        uint256 firstChildBalance
    ) {
        Node memory parent;
        parent.balance = 42;
        parent.children = new Node[](1);
        parent.children[0].balance = 99;

        root = parent;

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildBalance = root.children[0].balance;
    }
}
// ====
// compileViaYul: true
// ----
// f() -> 42, 1, 99
