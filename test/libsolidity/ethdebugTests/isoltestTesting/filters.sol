contract C {
    function f() public pure returns (uint) {
        return 42;
    }
}
// ----
// .resources.compilation.sources | length: 1
// C.contract | type: object
// C.contract | keys: ["definition", "name"]
// C.creation.instructions | type: array
// C.creation.environment | type: string
