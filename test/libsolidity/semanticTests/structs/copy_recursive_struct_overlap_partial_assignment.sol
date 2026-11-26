contract C {
    struct Node {
        Node[2][] pairs;
        uint256 v;
    }

    Node[3] t;

    function f() external returns (uint256, uint256, uint256) {
        t[0].pairs.push();
        t[0].pairs[0][0].v = 1;
        // The copy must overwrite t[1] and clear t[2].
        t[1].v = 7;
        t[2].v = 9;

        t = t[0].pairs[0];

        return (t[0].v, t[1].v, t[2].v);
    }
}
// ----
// f() -> 1, 0, 0
// gas irOptimized: 117976
// gas legacy: 125919
// gas legacyOptimized: 118182
// gas ssaCFGOptimized: 117932
