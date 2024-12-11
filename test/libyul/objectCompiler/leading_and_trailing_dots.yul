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
// Bytecode: 60025b5f600256
// Opcodes: PUSH1 0x2 JUMPDEST PUSH0 PUSH1 0x2 JUMP
// SourceMappings: 53:1:0:-:0;108:32;136:1;134:4;:::i
