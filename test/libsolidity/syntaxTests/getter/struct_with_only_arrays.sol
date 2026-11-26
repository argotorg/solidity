contract C {
    struct S {
        uint[] dynamicArray;
        uint[3] staticArray;
    }
    S public s;

    function f() external view {
        function () external view returns (S memory) asStruct = this.s;
    }
}
// ----
// Warning 2072: (150-203): Unused local variable.
