{
    function e(_._) {
        e(0)
    }
    e(2)
    function f(n._) {
        f(0)
    }
    f(2)
    function g(_.n) {
        g(0)
    }
    g(2)
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":53:54   */
//   0x02
//     /* "source":51:55   */
//   jumpf{code_section_1}
//
// code_section_1: assembly {
//         /* "source":136:137   */
//       0x00
//         /* "source":134:138   */
//       jumpf{code_section_1}
// }
// Bytecode: ef0001010008020002000500040400000000800001018000026002e500015fe50001
// Opcodes: 0xEF STOP ADD ADD STOP ADDMOD MUL STOP MUL STOP SDIV STOP DIV DIV STOP STOP STOP STOP DUP1 STOP ADD ADD DUP1 STOP MUL PUSH1 0x2 JUMPF 0x1 PUSH0 JUMPF 0x1
// SourceMappings: 53:1:0:-:0;51:4::i136:1:0:-:0;134:4::i
