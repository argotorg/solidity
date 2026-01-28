object "Contract" {
    code {
        f()
        g()

        function f() { revert(0, 0) }
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
//     /* "source":91:128   */
// tag_1:
//     /* "source":124:125   */
//   0x00
//     /* "source":114:126   */
//   dup1
//   revert
// Bytecode: 6003565b5f80fd
// Opcodes: PUSH1 0x3 JUMP JUMPDEST PUSH0 DUP1 REVERT
// SourceMappings: 53:3:0:-:0;:::i;91:37::-;124:1;114:12;
