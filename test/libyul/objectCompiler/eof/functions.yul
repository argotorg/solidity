object "a" {
    code {
        mstore(0, fun1(calldataload(0)))

        if calldataload(32) {
            non_ret_fun()
        }

        return(0, 32)

        function fun1(i) -> r {
            if i {
                r := 5
                leave
            }
            r := 99
        }

        function non_ret_fun() {
            revert(0, 0)
        }
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":74:75   */
//   0x00
//     /* "source":61:76   */
//   calldataload
//     /* "source":56:77   */
//   callf{code_section_1}
//     /* "source":53:54   */
//   0x00
//     /* "source":46:78   */
//   mstore
//     /* "source":107:109   */
//   0x20
//     /* "source":94:110   */
//   calldataload
//     /* "source":91:128   */
//   rjumpi{tag_1}
//     /* "source":22:386   */
// tag_2:
//     /* "source":151:153   */
//   0x20
//     /* "source":148:149   */
//   0x00
//     /* "source":141:154   */
//   return
//     /* "source":111:128   */
// tag_1:
//     /* "source":113:126   */
//   jumpf{code_section_2}
//
// code_section_1: assembly {
//         /* "source":217:294   */
//       rjumpi{tag_3}
//         /* "source":203:324   */
//     tag_4:
//         /* "source":312:314   */
//       0x63
//         /* "source":173:324   */
//       retf
//         /* "source":234:294   */
//     tag_3:
//         /* "source":257:258   */
//       0x05
//         /* "source":275:280   */
//       retf
// }
//
// code_section_2: assembly {
//         /* "source":376:377   */
//       0x00
//         /* "source":366:378   */
//       dup1
//       revert
// }
// Bytecode: ef000101000c020003001400090003040000000080000201010001008000025f35e300015f52602035e1000460205ff3e50002e100036063e46005e45f80fd
// Opcodes: 0xEF STOP ADD ADD STOP 0xC MUL STOP SUB STOP EQ STOP MULMOD STOP SUB DIV STOP STOP STOP STOP DUP1 STOP MUL ADD ADD STOP ADD STOP DUP1 STOP MUL PUSH0 CALLDATALOAD CALLF 0x1 PUSH0 MSTORE PUSH1 0x20 CALLDATALOAD RJUMPI 0x4 PUSH1 0x20 PUSH0 RETURN JUMPF 0x2 RJUMPI 0x3 PUSH1 0x63 RETF PUSH1 0x5 RETF PUSH0 DUP1 REVERT
// SourceMappings: 74:1:0:-:0;61:15;56:21::i;53:1::-;46:32;107:2;94:16;91:37;22:364;151:2;148:1;141:13;111:17;113:13::i217:77:0:-:0;203:121;312:2;173:151::o;234:60::-;257:1;275:5::o376:1:0:-:0;366:12;
