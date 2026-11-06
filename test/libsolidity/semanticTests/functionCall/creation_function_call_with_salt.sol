contract C {
    uint public i;
    constructor(uint newI) {
        i = newI;
    }
}
contract D {
    C c;
    constructor(uint v) {
        c = new C{salt: "abc"}(v);
    }
    function f() public returns (uint r) {
        return c.i();
    }
}
// ====
// EVMVersion: >=constantinople
// ----
// constructor(): 2 ->
// gas irOptimized: 138608
// gas irOptimized code: 52800
// gas legacy: 145935
// gas legacy code: 95600
// gas legacyOptimized: 138310
// gas legacyOptimized code: 53400
// gas ssaCFGOptimized: 138181
// gas ssaCFGOptimized code: 48400
// f() -> 2
