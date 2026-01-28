object "Contract" {
    code {
        g()

        function f() { mstore(0, 3) }
        function g() { mstore(0, 2) }
    }
}

// ====
// EVMVersion: >=shanghai
// bytecodeFormat: legacy
// optimizationPreset: none
// ----
// Assembly:
//     /* "source":41:44   */
//   tag_2
//   tag_1
//   jump	// in
// tag_2:
//     /* "source":29:98   */
//   stop
//     /* "source":55:92   */
// tag_1:
//     /* "source":88:89   */
//   0x02
//     /* "source":85:86   */
//   0x00
//     /* "source":78:90   */
//   mstore
//     /* "source":55:92   */
//   jump	// out
// Bytecode: 60056007565b005b60025f5256
// Opcodes: PUSH1 0x5 PUSH1 0x7 JUMP JUMPDEST STOP JUMPDEST PUSH1 0x2 PUSH0 MSTORE JUMP
// SourceMappings: 41:3:0:-:0;;:::i;:::-;29:69;55:37;88:1;85;78:12;55:37::o
