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
// bytecodeFormat: legacy
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "source":65:66   */
//   0x00
//     /* "source":59:67   */
//   dup1
//   sload
//     /* "source":133:225   */
//   dup1
//   iszero
//   tag_1
//   jumpi
//     /* "source":238:263   */
//   dup1
//     /* "source":243:247   */
//   0x01
//     /* "source":238:263   */
//   eq
//   tag_3
//   jumpi
//     /* "source":276:368   */
//   dup1
//     /* "source":281:285   */
//   0x02
//     /* "source":276:368   */
//   eq
//   tag_5
//   jumpi
//     /* "source":386:390   */
//   0x03
//     /* "source":381:406   */
//   eq
//   tag_7
//   jumpi
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
//     /* "source":426:427   */
//   0x00
//     /* "source":419:436   */
//   sstore
//     /* "source":108:406   */
//   stop
//     /* "source":286:368   */
// tag_5:
//     /* "source":314:354   */
//   pop
//   pop
//     /* "source":339:353   */
//   0xaabbccddeeff
//     /* "source":314:354   */
//   verbatimbytecode_506002
//     /* "source":426:427   */
//   0x00
//     /* "source":419:436   */
//   sstore
//     /* "source":108:406   */
//   stop
//     /* "source":248:263   */
// tag_3:
//     /* "source":250:261   */
//   pop
//   pop
//     /* "source":260:261   */
//   0x01
//     /* "source":426:427   */
//   0x00
//     /* "source":419:436   */
//   sstore
//     /* "source":108:406   */
//   stop
//     /* "source":143:225   */
// tag_1:
//     /* "source":171:211   */
//   pop
//   pop
//     /* "source":196:210   */
//   0xaabbccddeeff
//     /* "source":171:211   */
//   verbatimbytecode_506000
//     /* "source":426:427   */
//   0x00
//     /* "source":419:436   */
//   sstore
//     /* "source":108:406   */
//   stop
