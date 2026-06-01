contract C {
    function f() public pure {}
}
// ----
// .compilation.compiler.name: solc
// .compilation.compiler | type: object
// .compilation.compiler | keys: ["name", "version"]
// .compilation.id: <IGNORE>
// .compilation.sources | length: 1
// .compilation.sources[0].id: 0
// .compilation.sources[0].path: <IGNORE>
// .compilation.sources[0].contents: <IGNORE>
// .compilation.sources[0].language: Solidity
// .compilation:
// {
//     "compiler": {
//         "name": "solc",
//         "version": "<IGNORE>"
//     },
//     "id": "<IGNORE>",
//     "sources": [
//         {
//             "contents": "<IGNORE>",
//             "id": 0,
//             "language": "Solidity",
//             "path": "<IGNORE>"
//         }
//     ]
// }
