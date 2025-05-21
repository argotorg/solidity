PUSH [$] 0x0000
PUSH #[$] 0x0000

.sub
    PUSH [$] 0x0
    PUSH #[$] 0x2

    .sub
    .sub
    .sub
// ====
// outputs: InputAssemblyJSON,Assembly,Bytecode,Opcodes,SourceMappings
// ----
// InputAssemblyJSON: {
//     ".code": [
//         {
//             "name": "PUSH [$]",
//             "value": "0000"
//         },
//         {
//             "name": "PUSH #[$]",
//             "value": "0000"
//         }
//     ],
//     ".data": {
//         "0": {
//             ".code": [
//                 {
//                     "name": "PUSH [$]",
//                     "value": "0"
//                 },
//                 {
//                     "name": "PUSH #[$]",
//                     "value": "2"
//                 }
//             ],
//             ".data": {
//                 "0": {
//                     ".code": []
//                 },
//                 "1": {
//                     ".code": []
//                 },
//                 "2": {
//                     ".code": []
//                 }
//             }
//         }
//     }
// }
// Assembly:
//   dataOffset(sub_0)
//   dataSize(sub_0)
// stop
//
// sub_0: assembly {
//       dataOffset(sub_0)
//       dataSize(sub_2)
//     stop
//
//     sub_0: assembly {
//     }
//
//     sub_1: assembly {
//     }
//
//     sub_2: assembly {
//     }
// }
// Bytecode: 60056005fe60056000fe
// Opcodes: PUSH1 0x5 PUSH1 0x5 INVALID PUSH1 0x5 PUSH1 0x0 INVALID
// SourceMappings: :::-:0;
