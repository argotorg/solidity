contract C {
    function f() public view returns (uint256) {
        return msg.sender.balance;
    }
}


contract D {
    C c = new C();

    constructor() payable {}

    function f() public view returns (uint256) {
        return c.f();
    }
}
// ----
// constructor(), 27 wei ->
// gas irOptimized: 113668
// gas irOptimized code: 52800
// gas legacy: 117834
// gas legacy code: 100600
// gas legacyOptimized: 113457
// gas legacyOptimized code: 52400
// gas ssaCFGOptimized: 113348
// gas ssaCFGOptimized code: 48400
// f() -> 27
