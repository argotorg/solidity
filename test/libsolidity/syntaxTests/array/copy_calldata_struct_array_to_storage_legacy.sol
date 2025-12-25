contract C {
    struct S {
        uint256 a;
        uint256 b;
    }

    S[] storageArray;

    function copyFromCalldata(S[] calldata calldataArray) public {
        storageArray = calldataArray;
    }
}
// ====
// compileViaYul: false
// ----
// UnimplementedFeatureError 1834: (0-208): Copying of type struct C.S calldata[] calldata to storage is not supported in legacy (only supported by the IR pipeline). Hint: try compiling with `--via-ir` (CLI) or the equivalent `viaIR: true` (Standard JSON).
