{
  function f(x, y) {
    mstore(0x80, x)
    if calldataload(0) { sstore(y, y) }
  }

  f(0, 0)
}
// ====
// bytecodeFormat: >=EOFv1
// stackOptimization: true
// ----
//     /* "":95:96   */
//   0x00
//     /* "":90:97   */
//   dup1
//   callf{code_section_1}
//     /* "":0:99   */
//   stop
//
// code_section_1: assembly {
//         /* "":34:38   */
//       0x80
//         /* "":27:42   */
//       mstore
//         /* "":63:64   */
//       0x00
//         /* "":50:65   */
//       calldataload
//         /* "":47:82   */
//       rjumpi{tag_1}
//         /* "":21:86   */
//     tag_2:
//         /* "":4:86   */
//       pop
//       retf
//         /* "":66:82   */
//     tag_1:
//         /* "":68:80   */
//       dup1
//       sstore
//         /* "":66:82   */
//       0x00
//       rjump{tag_2}
// }
