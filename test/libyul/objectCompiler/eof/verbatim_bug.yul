object "a" {
    code {
        let dummy := 0xAABBCCDDEEFF
        let input := sload(0)
        let output

        switch input
        case 0x00 {
            // Note that due to a bug the following disappeared from the assembly output.
            output := verbatim_1i_1o(hex"506000", dummy)
        }
        case 0x01 {
            output := 1
        }
        case 0x02 {
            output := verbatim_1i_1o(hex"506002", dummy)
        }
        case 0x03 {
            output := 3
        }

        sstore(0, output)
    }
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "source":65:66   */
//   0x00
//     /* "source":59:67   */
//   sload
//     /* "source":94:95   */
//   0x00
//     /* "source":108:406   */
//   swap1
//     /* "source":133:225   */
//   dup1
//     /* "source":138:142   */
//   0x00
//     /* "source":133:225   */
//   eq
//   rjumpi{tag_1}
//     /* "source":108:406   */
// tag_2:
//     /* "source":238:263   */
//   dup1
//     /* "source":243:247   */
//   0x01
//     /* "source":238:263   */
//   eq
//   rjumpi{tag_3}
//     /* "source":108:406   */
// tag_4:
//     /* "source":276:368   */
//   dup1
//     /* "source":281:285   */
//   0x02
//     /* "source":276:368   */
//   eq
//   rjumpi{tag_5}
//     /* "source":108:406   */
// tag_6:
//     /* "source":386:390   */
//   0x03
//     /* "source":381:406   */
//   eq
//   rjumpi{tag_7}
//     /* "source":108:406   */
// tag_8:
//     /* "source":426:427   */
//   0x00
//     /* "source":419:436   */
//   sstore
//     /* "source":108:406   */
//   stop
//     /* "source":391:406   */
// tag_7:
//     /* "source":393:404   */
//   pop
//     /* "source":403:404   */
//   0x03
//     /* "source":391:406   */
//   rjump{tag_8}
//     /* "source":286:368   */
// tag_5:
//     /* "source":314:354   */
//   pop
//   pop
//     /* "source":339:353   */
//   0xaabbccddeeff
//     /* "source":314:354   */
//   verbatimbytecode_506002
//     /* "source":286:368   */
//   rjump{tag_8}
//     /* "source":248:263   */
// tag_3:
//     /* "source":250:261   */
//   pop
//   pop
//     /* "source":260:261   */
//   0x01
//     /* "source":248:263   */
//   rjump{tag_8}
//     /* "source":143:225   */
// tag_1:
//     /* "source":171:211   */
//   pop
//   pop
//     /* "source":196:210   */
//   0xaabbccddeeff
//     /* "source":171:211   */
//   verbatimbytecode_506000
//     /* "source":143:225   */
//   rjump{tag_8}
