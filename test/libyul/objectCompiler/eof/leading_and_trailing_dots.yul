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
// bytecodeFormat: >=EOFv1
// outputs: Assembly
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
