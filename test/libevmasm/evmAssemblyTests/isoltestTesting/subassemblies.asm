PUSH 0x2
DUP1
ADD

.sub
    PUSH 0x42
    DUP1
    MUL

.sub
    STOP
// ====
// outputs: InputAssemblyJSON,Assembly,Bytecode,Opcodes,SourceMappings
// ----
// InputAssemblyJSON: {
//     ".code": [
//         {
//             "name": "PUSH",
//             "value": "2"
//         },
//         {
//             "name": "DUP1"
//         },
//         {
//             "name": "ADD"
//         }
//     ],
//     ".data": {
//         "0": {
//             ".code": [
//                 {
//                     "name": "PUSH",
//                     "value": "42"
//                 },
//                 {
//                     "name": "DUP1"
//                 },
//                 {
//                     "name": "MUL"
//                 }
//             ]
//         },
//         "1": {
//             ".code": [
//                 {
//                     "name": "STOP"
//                 }
//             ]
//         }
//     }
// }
// Assembly:
//   0x02
//   dup1
//   add
// stop
//
// sub_0: assembly {
//       0x42
//       dup1
//       mul
// }
//
// sub_1: assembly {
//       stop
// }
// Bytecode: 60028001fe
// Opcodes: PUSH1 0x2 DUP1 ADD INVALID
// SourceMappings: :::-:0;;
