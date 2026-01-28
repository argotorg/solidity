object "Contract" {
    code {
        f()
        g()

        function f() { revert(0, 0) }
        function g() { mstore(0, 2) }
    }
}

// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// optimizationPreset: none
// ----
// Assembly:
//     /* "source":53:56   */
//   jumpf{code_section_1}
//
// code_section_1: assembly {
//         /* "source":124:125   */
//       0x00
//         /* "source":114:126   */
//       dup1
//       revert
// }
// Bytecode: ef000101000802000200030003040000000080000000800002e500015f80fd
// Opcodes: 0xEF STOP ADD ADD STOP ADDMOD MUL STOP MUL STOP SUB STOP SUB DIV STOP STOP STOP STOP DUP1 STOP STOP STOP DUP1 STOP MUL JUMPF 0x1 PUSH0 DUP1 REVERT
// SourceMappings: 53:3:0:i:0124:1:0:-:0;114:12;
