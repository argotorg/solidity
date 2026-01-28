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
// bytecodeFormat: legacy
// outputs: Assembly
// ----
// Assembly:
//     /* "source":53:54   */
//   0x02
//     /* "source":108:140   */
// tag_1:
//     /* "source":136:137   */
//   0x00
//     /* "source":134:138   */
//   tag_1
//   jump	// in
