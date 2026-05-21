contract C {
    function f() public pure {}
}
// ----
// .compilation.compiler.name: solc
// .compilation.compiler | type: object
// .compilation.compiler | keys: ["name", "version"]
// .compilation:
// {
//     "compiler": {
//         "name": "solc",
//         "version": "<IGNORE>"
//     }
// }
