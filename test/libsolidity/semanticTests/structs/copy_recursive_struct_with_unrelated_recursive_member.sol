contract C {
    struct Unrelated {
        Unrelated[] children;
        uint256 v;
    }
    struct Node {
        Node[] children;
        Unrelated[] others;
        uint256 v;
    }

    Node n1;
    Node n2;

    function f() external returns (uint256, uint256, uint256, uint256) {
        n2.children.push();
        n2.children[0].v = 3;
        n2.others.push();
        n2.others[0].v = 7;
        n2.others[0].children.push();
        n2.others[0].children[0].v = 11;
        n2.v = 1;

        n1 = n2;

        return (n1.v, n1.children[0].v, n1.others[0].v, n1.others[0].children[0].v);
    }
}
// ----
// f() -> 1, 3, 7, 11
// gas irOptimized: 349419
// gas legacy: 354241
// gas legacyOptimized: 349164
// gas ssaCFGOptimized: 349431
