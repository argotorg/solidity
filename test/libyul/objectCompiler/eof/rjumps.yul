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
//   iszero
//   rjumpi{tag_2}
//     /* "source":66:67   */
//   0x01
//     /* "source":63:64   */
//   0x00
//     /* "source":56:68   */
//   mstore
//     /* "source":22:112   */
// tag_2:
//     /* "source":93:95   */
//   0x20
//     /* "source":90:91   */
//   0x00
//     /* "source":83:96   */
//   return
// Bytecode: ef0001010004020001000e0400000000800002600115e1000460015f5260205ff3
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP 0xE DIV STOP STOP STOP STOP DUP1 STOP MUL PUSH1 0x1 ISZERO RJUMPI 0x4 PUSH1 0x1 PUSH0 MSTORE PUSH1 0x20 PUSH0 RETURN
// SourceMappings: 49:4:0:-:0;46:24;-1:-1:-1;66:1:0;63;56:12;22:90;93:2;90:1;83:13
