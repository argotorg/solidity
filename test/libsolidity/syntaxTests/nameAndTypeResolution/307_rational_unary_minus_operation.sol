contract test {
    function f() pure public {
        ufixed16x2 a = 3.25;
        fixed16x2 b = -3.25;
        a; b;
    }
}
// ====
// bytecodeFormat: legacy
// ----
// UnimplementedFeatureError 1834: (0-126): Not yet implemented - FixedPointType.
