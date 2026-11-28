contract C {
    struct S { mapping(uint => uint) m; }
    struct R { R[] r; }
    function f() pure public {
        abi.decode("", (S));
        abi.decode("", (R));
    }
}
// ----
// TypeError 9611: (134-135): Decoding type struct C.S memory not supported.
// TypeError 9611: (163-164): Decoding type struct C.R memory not supported.
