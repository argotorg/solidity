contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    struct Wrapper {
        Node node;
    }

    Wrapper wrapper;

    function f() external returns (uint256 sourceBalance, uint256 targetBalance, uint256 targetChildCount, uint256 targetGrandChildBalance) {
        wrapper.node.balance = 5;
        wrapper.node.children.push();
        wrapper.node.children[0].balance = 11;
        wrapper.node.children[0].children.push();
        wrapper.node.children[0].children[0].balance = 22;

        sourceBalance = wrapper.node.children[0].balance;

        // The recursive struct Node is a member of the non-recursive struct Wrapper.
        // Target (wrapper.node) contains the source (wrapper.node.children[0]), the
        // same overlap direction as the top-level case, reached through the wrapper.
        wrapper.node = wrapper.node.children[0];

        targetBalance = wrapper.node.balance;
        targetChildCount = wrapper.node.children.length;
        targetGrandChildBalance = wrapper.node.children[0].balance;
    }
}
// ----
// f() -> 11, 11, 1, 22
// gas irOptimized: 111524
// gas legacy: 116188
// gas legacyOptimized: 111367
// gas ssaCFGOptimized: 111524
