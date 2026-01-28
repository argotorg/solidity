contract test {
    function f() public {
        uint64 a = 3;
        int64 b = 4;
        fixed c = b;
        ufixed d = a;
        c; d;
    }
}
// ====
// compileViaYul: true
// ----
// Warning 2018: (20-147): Function state mutability can be restricted to pure
// UnimplementedFeatureError 1834: (93-104): Fixed point types not implemented.
