// sub_0 and children
PUSH #[$] 0x0000
// negative indices for nested subobjects in DFS order
PUSH #[$] 0x000000000000000000000000000000000000000000000000ffffffffffffffff
PUSH #[$] 0x000000000000000000000000000000000000000000000000fffffffffffffffe
PUSH #[$] 0x000000000000000000000000000000000000000000000000fffffffffffffffd
PUSH #[$] 0x000000000000000000000000000000000000000000000000fffffffffffffffc
// sub_1 and children
PUSH #[$] 0x0001
PUSH #[$] 0x000000000000000000000000000000000000000000000000fffffffffffffffb

.sub
    // referencing sub_0.sub_0 from inside sub_0
    PUSH #[$] 0x0000
    // referencing sub_0.sub_0.sub_0 from inside sub_0
    PUSH #[$] 0x000000000000000000000000000000000000000000000000ffffffffffffffff
    .sub
        .sub
    .sub
    .sub
.sub
    .sub
// ----
// Assembly:
//   dataSize(sub_0)
//   dataSize(sub_0.sub_0)
//   dataSize(sub_0.sub_0.sub_0)
//   dataSize(sub_0.sub_1)
//   dataSize(sub_0.sub_2)
//   dataSize(sub_1)
//   dataSize(sub_1.sub_0)
// stop
//
// sub_0: assembly {
//       dataSize(sub_0)
//       dataSize(sub_0.sub_0)
//     stop
//
//     sub_0: assembly {
//         stop
//
//         sub_0: assembly {
//         }
//     }
//
//     sub_1: assembly {
//     }
//
//     sub_2: assembly {
//     }
// }
//
// sub_1: assembly {
//     stop
//
//     sub_0: assembly {
//     }
// }
// Bytecode: 6005600160006000600060016000fe
// Opcodes: PUSH1 0x5 PUSH1 0x1 PUSH1 0x0 PUSH1 0x0 PUSH1 0x0 PUSH1 0x1 PUSH1 0x0 INVALID
// SourceMappings: :::-:0;;;;;;
