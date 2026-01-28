object "a" {
    code {
        if true {
            mstore(0, 1)
        }

        return(0, 32)
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":49:53   */
//   0x01
//     /* "source":46:70   */
//   rjumpi{tag_1}
//     /* "source":22:112   */
// tag_2:
//     /* "source":93:95   */
//   0x20
//     /* "source":90:91   */
//   0x00
//     /* "source":83:96   */
//   return
//     /* "source":54:70   */
// tag_1:
//     /* "source":66:67   */
//   0x01
//     /* "source":63:64   */
//   0x00
//     /* "source":56:68   */
//   mstore
//     /* "source":54:70   */
//   rjump{tag_2}
// Bytecode: ef0001010004020001001004000000008000026001e1000460205ff360015f52e0fff5
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP LT DIV STOP STOP STOP STOP DUP1 STOP MUL PUSH1 0x1 RJUMPI 0x4 PUSH1 0x20 PUSH0 RETURN PUSH1 0x1 PUSH0 MSTORE RJUMP 0xFFF5
// SourceMappings: 49:4:0:-:0;46:24;22:90;93:2;90:1;83:13;54:16;66:1;63;56:12;54:16
