contract C {
    uint[24] a;
    bool flag = true;

    // The first `a[i] = 2` must survive UnusedStoreEliminator: `i` is reassigned in an `if`
    // after `k` was computed from it, so that `a[k]` reads the slot written by `a[i] = 2`.
    // The test only detects the bug when run with --optimize via IR.
    function f() external returns (uint) {
        uint i;
        if (flag) i++;
        uint k = i + 2;
        if (flag) i += 2;
        a[i] = 2;
        uint r = a[k];
        a[i] = 5;
        return r;
    }
}
// ----
// f() -> 2
