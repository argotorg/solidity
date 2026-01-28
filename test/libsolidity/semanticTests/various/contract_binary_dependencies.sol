contract A {
    function f() public {
        new B();
    }
}


contract B {
    function f() public {}
}


contract C {
    function f() public {
        new B();
    }
}
// ----
// constructor() ->
// gas irOptimized: 56611
// gas irOptimized code: 39400
