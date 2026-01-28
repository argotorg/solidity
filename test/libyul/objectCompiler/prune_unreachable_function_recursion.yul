object "Contract" {
    code {
        f()
        g()

        function f() { f() }
        function g() { mstore(0, 2) }
    }
}

// ====
// EVMVersion: >=shanghai
// bytecodeFormat: legacy
// optimizationPreset: none
// ----
// Assembly:
//     /* "source":53:56   */
//   tag_1
//   jump	// in
//     /* "source":91:119   */
// tag_1:
//     /* "source":114:117   */
//   tag_1
//   jump	// in
// Bytecode: 6003565b600356
// Opcodes: PUSH1 0x3 JUMP JUMPDEST PUSH1 0x3 JUMP
// SourceMappings: 53:3:0:-:0;:::i;91:28::-;114:3;:::i
