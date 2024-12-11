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
// Bytecode: ef0001010004020001004c04000000008000045f545f90805f14e1003380600114e1002580600214e1000f600314e100035f5500506003e0fff7505065aabbccddeeff506002e0ffe850506001e0ffe1505065aabbccddeeff506000e0ffd2
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP 0x4C DIV STOP STOP STOP STOP DUP1 STOP DIV PUSH0 SLOAD PUSH0 SWAP1 DUP1 PUSH0 EQ RJUMPI 0x33 DUP1 PUSH1 0x1 EQ RJUMPI 0x25 DUP1 PUSH1 0x2 EQ RJUMPI 0xF PUSH1 0x3 EQ RJUMPI 0x3 PUSH0 SSTORE STOP POP PUSH1 0x3 RJUMP 0xFFF7 POP POP PUSH6 0xAABBCCDDEEFF POP PUSH1 0x2 RJUMP 0xFFE8 POP POP PUSH1 0x1 RJUMP 0xFFE1 POP POP PUSH6 0xAABBCCDDEEFF POP PUSH1 0x0 RJUMP 0xFFD2
// SourceMappings: 65:1:0:-:0;59:8;94:1;108:298;133:92;138:4;133:92;;108:298;238:25;243:4;238:25;;108:298;276:92;281:4;276:92;;108:298;386:4;381:25;;108:298;426:1;419:17;108:298;391:15;393:11;403:1;391:15;286:82;314:40;;339:14;314:40;286:82;248:15;250:11;;260:1;248:15;143:82;171:40;;196:14;171:40;143:82
