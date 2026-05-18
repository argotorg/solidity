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
// gas irOptimized: 113700
// gas irOptimized code: 53200
// gas legacy: 117834
// gas legacy code: 100600
// gas legacyOptimized: 113457
// gas legacyOptimized code: 52400
// f() -> 27
