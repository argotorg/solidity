contract C {
    struct Node {
        Node[] children;
        uint256 v;
    }

    Node[3] fixedNodes;
    Node[] dynamicNodes;

    function f() external returns (uint256, uint256, uint256, uint256) {
        fixedNodes[0].v = 1;
        fixedNodes[1].children.push();
        fixedNodes[1].children[0].v = 7;
        fixedNodes[2].v = 3;

        dynamicNodes = fixedNodes;

        return (dynamicNodes.length, dynamicNodes[0].v, dynamicNodes[2].v, dynamicNodes[1].children[0].v);
    }
}
// ----
// f() -> 3, 1, 3, 7
// gas irOptimized: 240772
// gas legacy: 245728
// gas legacyOptimized: 241011
// gas ssaCFGOptimized: 240868
