contract test {
    struct myStruct {
        ufixed a;
        int b;
    }
    myStruct a = myStruct(3.125, 3);
}
// ====
// bytecodeFormat: legacy
// ----
// UnimplementedFeatureError 1834: (0-115): Not yet implemented - FixedPointType.
