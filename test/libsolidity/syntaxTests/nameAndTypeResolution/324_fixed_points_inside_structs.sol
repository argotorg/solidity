contract test {
    struct myStruct {
        ufixed a;
        int b;
    }
    myStruct a = myStruct(3.125, 3);
}
// ====
// compileViaYul: true
// ----
// UnimplementedFeatureError 1834: (94-112): Fixed point types not implemented.
