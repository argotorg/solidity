contract C {
    uint constant a = 0 ** (-1);
    uint constant b = 0 ** (-2);
    function f() public pure returns (uint) {
        return 0 ** (-1);
    }
}
// ----
// TypeError 2271: (35-44): Built-in binary operator ** cannot be applied to types int_const 0 and int_const -1.
// TypeError 2271: (68-77): Built-in binary operator ** cannot be applied to types int_const 0 and int_const -2.
// TypeError 2271: (140-149): Built-in binary operator ** cannot be applied to types int_const 0 and int_const -1.
