contract C {
    struct S {
        uint[] dynamicArray;
        uint[3] staticArray;
    }
    S public s;

    function f() external view {
        function () external view returns (S memory) asStruct = this.s;
        asStruct;
    }
}
// ----
// TypeError 5359: (96-106): The struct has all its members omitted, therefore the getter cannot return any values.
// TypeError 9582: (206-212): Member "s" not found or not visible after argument-dependent lookup in contract C.
