contract A {
    uint x;
    constructor() {
        x = 42;
    }
    function f() public returns(uint256) {
        return x;
    }
}
contract B is A {
    uint public y = f();
}
// ====
// compileViaYul: true
// targetContract: B
// ----
// constructor() ->
// gas irOptimized: 99436
// gas irOptimized code: 20200
// gas ssaCFGOptimized: 99337
// gas ssaCFGOptimized code: 18800
// y() -> 42
