contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node[] roots;

    function f() external returns (uint256 sourceBalance, uint256 targetBalance, uint256 targetChildCount) {
        roots.push();
        roots[0].children.push();
        roots[0].children[0].balance = 42;
        sourceBalance = roots[0].children[0].balance;

        roots[0] = roots[0].children[0];

        targetBalance = roots[0].balance;
        targetChildCount = roots[0].children.length;
    }
}
// ----
// f() -> 42, 42, 0
