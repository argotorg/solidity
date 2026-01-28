object "Contract" {
    code {
        g()

        function f() { mstore(0, 3) }
        function g() { mstore(0, 2) }
    }
}

// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// optimizationPreset: none
// ----
// Assembly:
//     /* "source":41:44   */
//   callf{code_section_1}
//     /* "source":29:98   */
//   stop
//
// code_section_1: assembly {
//         /* "source":88:89   */
//       0x02
//         /* "source":85:86   */
//       0x00
//         /* "source":78:90   */
//       mstore
//         /* "source":55:92   */
//       retf
// }
// Bytecode: ef000101000802000200040005040000000080000000000002e300010060025f52e4
// Opcodes: 0xEF STOP ADD ADD STOP ADDMOD MUL STOP MUL STOP DIV STOP SDIV DIV STOP STOP STOP STOP DUP1 STOP STOP STOP STOP STOP MUL CALLF 0x1 STOP PUSH1 0x2 PUSH0 MSTORE RETF
// SourceMappings: 41:3:0:i:0;29:69::-88:1:0:-:0;85;78:12;55:37::o
