contract C {
    function set(uint value) external {
        assembly {
            tstore(0, value)
        }
    }

    function get() external view returns (uint value) {
        assembly {
            value := tload(0)
        }
    }

    function terminate(address payable a) external {
        selfdestruct(a);
    }
}

contract D {
    C public c;

    constructor() {
        c = new C();
    }

    function destroy() external {
        c.set(42);
        c.terminate(payable(address(this)));
        assert(c.get() == 42);
    }

    function createAndDestroy() external {
        c = new C();
        c.set(42);
        c.terminate(payable(address(this)));
        assert(c.get() == 42);
    }
}
// ====
// EVMVersion: >=cancun
// ----
// constructor() ->
// gas irOptimized: 126804
// gas irOptimized code: 214800
// gas legacy: 149480
// gas legacy code: 501200
// gas legacyOptimized: 125119
// gas legacyOptimized code: 196000
// gas ssaCFGOptimized: 125418
// gas ssaCFGOptimized code: 197000
// destroy() ->
// createAndDestroy() ->
// gas legacy: 67048
// gas legacy code: 92600
// gas legacyOptimized: 65640
// gas legacyOptimized code: 38200
