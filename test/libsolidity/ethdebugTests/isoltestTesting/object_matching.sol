contract C {
    function f() public pure returns (uint) {
        return 42;
    }
}
// ----
// C.contract:
// {
//     "definition": {
//         "source": {
//             "id": 0,
//             "type": "source"
//         }
//     },
//     "name": "C"
// }
// C.creation.instructions[0]:
// {
//     "context": {
//         "code": {
//             "range": {
//                 "length": 85,
//                 "offset": 59
//             },
//             "source": {
//                 "id": 0,
//                 "type": "source"
//             }
//         }
//     },
//     "offset": 0,
//     "operation": {
//         "arguments": [
//             "0x80"
//         ],
//         "mnemonic": "PUSH1"
//     }
// }
