//
//// comment
    // comment
CALLVALUE // 0xff
CALLVALUE //0xff

PUSH 0xff // comment // //0xff
//

//
// ====
// outputs: InputAssemblyJSON,Assembly,Bytecode,Opcodes,SourceMappings
// ----
// InputAssemblyJSON: {
//     ".code": [
//         {
//             "name": "CALLVALUE"
//         },
//         {
//             "name": "CALLVALUE"
//         },
//         {
//             "name": "PUSH",
//             "value": "ff"
//         }
//     ]
// }
// Assembly:
//   callvalue
//   callvalue
//   0xff
// Bytecode: 343460ff
// Opcodes: CALLVALUE CALLVALUE PUSH1 0xFF
// SourceMappings: :::-:0;;
