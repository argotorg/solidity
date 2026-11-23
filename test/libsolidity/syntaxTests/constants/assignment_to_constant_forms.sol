contract C {
    uint constant a = 1;
    uint x;
    function f() public {
        a += 1;
        a++;
        --a;
        delete a;
        (a, x) = (1, 2);
        (a) = 2;
        C.a = 2;
    }
}
// ----
// TypeError 6520: (84-85): Cannot assign to a constant variable.
// TypeError 6520: (100-101): Cannot assign to a constant variable.
// TypeError 6520: (115-116): Cannot assign to a constant variable.
// TypeError 6520: (133-134): Cannot assign to a constant variable.
// TypeError 6520: (145-146): Cannot assign to a constant variable.
// TypeError 6520: (170-171): Cannot assign to a constant variable.
// TypeError 4247: (186-189): Expression has to be an lvalue.
