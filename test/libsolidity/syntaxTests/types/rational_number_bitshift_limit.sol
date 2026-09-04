contract c {
    function f() public pure {
        int a;
        a = 1 << 4095; // shift is fine, but result too large
        a = 1 << 4096; // too large, result is truncated to 0
        a = (1E1233) << 2; // too large, result is truncated to 0
    }
}
// ----
// TypeError 7407: (71-80): Type int_const 5221...(1225 digits omitted)...5168 is not implicitly convertible to expected type int256. Literal is too large to fit in int256.
