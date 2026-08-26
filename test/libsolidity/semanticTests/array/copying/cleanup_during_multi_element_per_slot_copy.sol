contract C {
    uint32[] s;
    constructor()
    {
        s.push();
        s.push();
    }
    function f() external returns (uint)
    {
        (s[1], s) = (4, [0]);
        s = [0];
        s.push();
        return s[1];
        // used to return 4 via IR.
    }
}
// ----
// constructor()
// gas irOptimized: 89937
// gas irOptimized code: 147400
// gas legacy: 102233
// gas legacy code: 292000
// gas legacyOptimized: 83852
// gas legacyOptimized code: 101600
// gas ssaCFGOptimized: 88977
// gas ssaCFGOptimized code: 141800
// f() -> 0
