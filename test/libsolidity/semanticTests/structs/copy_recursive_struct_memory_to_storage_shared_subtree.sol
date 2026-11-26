contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (
        uint256 targetBalance,
        uint256 targetChildCount,
        uint256 firstChildBalance,
        uint256 secondChildBalance
    ) {
        Node memory shared;
        shared.balance = 99;

        Node memory parent;
        parent.balance = 42;
        parent.children = new Node[](2);
        parent.children[0] = shared;
        parent.children[1] = shared;

        root = parent;

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildBalance = root.children[0].balance;
        secondChildBalance = root.children[1].balance;
    }
}
// ====
// compileViaYul: true
// ----
// f() -> 42, 2, 99, 99
// gas irOptimized: 116436
// gas ssaCFGOptimized: 116398
