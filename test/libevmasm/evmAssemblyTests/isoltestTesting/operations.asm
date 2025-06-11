NUMBER
SLOAD
ADDRESS
ORIGIN
ADD
DUP1
SWAP1
MSTORE8
STOP
// ====
// outputs: InputAssemblyJSON,Assembly,Bytecode,Opcodes,SourceMappings
// ----
// InputAssemblyJSON: {
//     ".code": [
//         {
//             "name": "NUMBER"
//         },
//         {
//             "name": "SLOAD"
//         },
//         {
//             "name": "ADDRESS"
//         },
//         {
//             "name": "ORIGIN"
//         },
//         {
//             "name": "ADD"
//         },
//         {
//             "name": "DUP1"
//         },
//         {
//             "name": "SWAP1"
//         },
//         {
//             "name": "MSTORE8"
//         },
//         {
//             "name": "STOP"
//         }
//     ]
// }
// Assembly:
//   sload(number)
//   add(origin, address)
//   dup1
//   swap1
//   mstore8
//   stop
// Bytecode: 435430320180905300
// Opcodes: NUMBER SLOAD ADDRESS ORIGIN ADD DUP1 SWAP1 MSTORE8 STOP
// SourceMappings: :::-:0;;;;;;;;
