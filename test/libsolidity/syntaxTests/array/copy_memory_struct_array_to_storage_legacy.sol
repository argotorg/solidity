contract C {
    struct S {
        uint256 a;
        uint256 b;
    }

    S[] storageArray;

    function copyFromMemory() public {
        S[] memory memArray = new S[](3);
        storageArray = memArray;
    }
}
// ====
// compileViaYul: false
// ----
// UnimplementedFeatureError 1834: (0-217): Copying of type struct C.S memory[] memory to storage is not supported in legacy (only supported by the IR pipeline). Hint: try compiling with `--via-ir` (CLI) or the equivalent `viaIR: true` (Standard JSON).
