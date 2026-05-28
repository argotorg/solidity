contract C {
    function f() public {}
}
// ====
// compileViaSSACFG: true
// ----
// .compilation.compiler.name: solc
// .resources.compilation.sources | length: 1
// C.contract.name: C
// C.creation.environment: create
// C.runtime.environment: call
// C.creation.instructions | type: array
// C.runtime.instructions | type: array
