contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (uint256 targetBalance, uint256 targetChildCount) {
        Node memory source;
        source.balance = 42;

        root = source;

        targetBalance = root.balance;
        targetChildCount = root.children.length;
    }
}
// ====
// compileViaYul: true
// ----
// f() -> 42, 0
