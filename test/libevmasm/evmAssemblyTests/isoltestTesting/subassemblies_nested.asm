TIMESTAMP
TIMESTAMP

.sub
    TIMESTAMP

    .sub
        TIMESTAMP
    .sub
        TIMESTAMP
        .sub
            TIMESTAMP
            .sub
                TIMESTAMP
    .sub
        TIMESTAMP
.sub
    NUMBER
    SLOAD
    .sub
        NUMBER
        MLOAD
        .sub
            NUMBER
            TLOAD

// ====
// outputs: InputAssemblyJSON,Assembly,Bytecode,Opcodes,SourceMappings
// ----
// InputAssemblyJSON: {
//     ".code": [
//         {
//             "name": "TIMESTAMP"
//         },
//         {
//             "name": "TIMESTAMP"
//         }
//     ],
//     ".data": {
//         "0": {
//             ".code": [
//                 {
//                     "name": "TIMESTAMP"
//                 }
//             ],
//             ".data": {
//                 "0": {
//                     ".code": [
//                         {
//                             "name": "TIMESTAMP"
//                         }
//                     ]
//                 },
//                 "1": {
//                     ".code": [
//                         {
//                             "name": "TIMESTAMP"
//                         }
//                     ],
//                     ".data": {
//                         "0": {
//                             ".code": [
//                                 {
//                                     "name": "TIMESTAMP"
//                                 }
//                             ],
//                             ".data": {
//                                 "0": {
//                                     ".code": [
//                                         {
//                                             "name": "TIMESTAMP"
//                                         }
//                                     ]
//                                 }
//                             }
//                         }
//                     }
//                 },
//                 "2": {
//                     ".code": [
//                         {
//                             "name": "TIMESTAMP"
//                         }
//                     ]
//                 }
//             }
//         },
//         "1": {
//             ".code": [
//                 {
//                     "name": "NUMBER"
//                 },
//                 {
//                     "name": "SLOAD"
//                 }
//             ],
//             ".data": {
//                 "0": {
//                     ".code": [
//                         {
//                             "name": "NUMBER"
//                         },
//                         {
//                             "name": "MLOAD"
//                         }
//                     ],
//                     ".data": {
//                         "0": {
//                             ".code": [
//                                 {
//                                     "name": "NUMBER"
//                                 },
//                                 {
//                                     "name": "TLOAD"
//                                 }
//                             ]
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }
// Assembly:
//   timestamp
//   timestamp
// stop
//
// sub_0: assembly {
//       timestamp
//     stop
//
//     sub_0: assembly {
//           timestamp
//     }
//
//     sub_1: assembly {
//           timestamp
//         stop
//
//         sub_0: assembly {
//               timestamp
//             stop
//
//             sub_0: assembly {
//                   timestamp
//             }
//         }
//     }
//
//     sub_2: assembly {
//           timestamp
//     }
// }
//
// sub_1: assembly {
//       sload(number)
//     stop
//
//     sub_0: assembly {
//           mload(number)
//         stop
//
//         sub_0: assembly {
//               tload(number)
//         }
//     }
// }
// Bytecode: 4242fe
// Opcodes: TIMESTAMP TIMESTAMP INVALID
// SourceMappings: :::-:0;
