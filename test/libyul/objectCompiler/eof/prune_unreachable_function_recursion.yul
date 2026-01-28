object "Contract" {
    code {
        f()
        g()

        function f() { f() }
        function g() { mstore(0, 2) }
    }
}

// ====
// bytecodeFormat: >=EOFv1
// optimizationPreset: none
// ----
// Assembly:
//     /* "source":53:56   */
//   jumpf{code_section_1}
//
// code_section_1: assembly {
//         /* "source":114:117   */
//       jumpf{code_section_1}
// }
// Bytecode: ef000101000802000200030003040000000080000000800000e50001e50001
// Opcodes: 0xEF STOP ADD ADD STOP ADDMOD MUL STOP MUL STOP SUB STOP SUB DIV STOP STOP STOP STOP DUP1 STOP STOP STOP DUP1 STOP STOP JUMPF 0x1 JUMPF 0x1
// SourceMappings: 53:3:0:i:0114:3:0:i:0
