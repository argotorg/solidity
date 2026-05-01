contract C {
    function f(fixed num, ufixed unum) public pure returns (bool) {
        // Comparing a fractional rational literal with a fixed-point variable
        // must succeed regardless of the operand order.
        bool a = (num > 2.5);
        bool b = (2.5 < num);
        bool c = (2.5 == num);
        bool d = (num != 2.5);
        bool e = (unum >= 1.5);
        bool f_ = (1.5 <= unum);
        return a && b && c && d && e && f_;
    }
}
// ----
// UnimplementedFeatureError 1834: (0-455): Fixed point types not implemented.
