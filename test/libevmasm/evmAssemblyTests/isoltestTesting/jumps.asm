PUSH [tag] 1
JUMP
tag 1
PUSH 0x01
JUMPI
PUSH [tag] 0x012AB
tag 0x012AB
// ====
// outputs: InputAssemblyJSON,Assembly,Bytecode,Opcodes,SourceMappings
// ----
// InputAssemblyJSON: {
//     ".code": [
//         {
//             "name": "PUSH [tag]",
//             "value": "1"
//         },
//         {
//             "name": "JUMP"
//         },
//         {
//             "name": "tag",
//             "value": "1"
//         },
//         {
//             "name": "JUMPDEST"
//         },
//         {
//             "name": "PUSH",
//             "value": "01"
//         },
//         {
//             "name": "JUMPI"
//         },
//         {
//             "name": "PUSH [tag]",
//             "value": "0x012AB"
//         },
//         {
//             "name": "tag",
//             "value": "0x012AB"
//         },
//         {
//             "name": "JUMPDEST"
//         }
//     ]
// }
// Assembly:
//   jump(tag_1)
// tag_1:
//   0x01
//   jumpi
//   tag_4779
// tag_4779:
// Bytecode: 6003565b60015760095b
// Opcodes: PUSH1 0x3 JUMP JUMPDEST PUSH1 0x1 JUMPI PUSH1 0x9 JUMPDEST
// SourceMappings: :::-:0;;;;;;
