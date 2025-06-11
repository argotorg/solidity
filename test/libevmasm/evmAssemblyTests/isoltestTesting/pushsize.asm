PUSHSIZE

.sub
    PUSHSIZE
// ====
// outputs: InputAssemblyJSON,Assembly,Bytecode,Opcodes,SourceMappings
// ----
// InputAssemblyJSON: {
//     ".code": [
//         {
//             "name": "PUSHSIZE"
//         }
//     ],
//     ".data": {
//         "0": {
//             ".code": [
//                 {
//                     "name": "PUSHSIZE"
//                 }
//             ]
//         }
//     }
// }
// Assembly:
//   bytecodeSize
// stop
//
// sub_0: assembly {
//       bytecodeSize
// }
// Bytecode: 6003fe
// Opcodes: PUSH1 0x3 INVALID
// SourceMappings: :::-:0
