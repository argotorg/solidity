contract test {
    function f() public {
        fixed c = 3;
        ufixed d = 4;
        c; d;
    }
}
// ====
// compileViaYul: true
// ----
// Warning 2018: (20-104): Function state mutability can be restricted to pure
// UnimplementedFeatureError 1834: (50-61): Fixed point types not implemented.
