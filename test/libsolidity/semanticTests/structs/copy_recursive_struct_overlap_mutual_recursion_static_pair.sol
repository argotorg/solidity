contract C {
    struct NodeA {
        NodeB[] children;
        uint256 v;
    }
    struct NodeB {
        NodeA[2] pair;
        uint256 w;
    }

    NodeA[] nodes;

    function f() external returns (uint256, uint256, uint256) {
        nodes.push();
        nodes[0].children.push();
        nodes[0].children[0].pair[0].v = 2;
        nodes[0].children[0].pair[1].v = 3;

        nodes = nodes[0].children[0].pair;

        return (nodes.length, nodes[0].v, nodes[1].v);
    }
}
// ----
// f() -> 2, 2, 3
// gas irOptimized: 135183
// gas legacy: 142103
// gas legacyOptimized: 135286
// gas ssaCFGOptimized: 135192
