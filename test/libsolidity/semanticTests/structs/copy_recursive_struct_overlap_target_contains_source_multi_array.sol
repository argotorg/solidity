contract C {
    struct Node {
        uint256 balance;
        Node[] children;
        Node[] secondChildren;
    }

    Node root;

    function f() external returns (uint256 targetBalance, uint256 targetChildCount, uint256 targetSecondChildCount, uint256 targetSecondChildBalance) {
        root.children.push();
        root.children[0].balance = 42;
        root.children[0].secondChildren.push();
        root.children[0].secondChildren[0].balance = 99;

        root = root.children[0];

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        targetSecondChildCount = root.secondChildren.length;
        targetSecondChildBalance = root.secondChildren[0].balance;
    }
}
// ----
// f() -> 42, 0, 1, 99
// gas irOptimized: 155016
// gas legacy: 162185
// gas legacyOptimized: 155054
// gas ssaCFGOptimized: 155056
