
PUSH 0x2

.sub
    PUSH 0x1
    PUSH 0x1
    // random small integer:
    PUSH 0x11f3d2be
    // largest non-computable:
    PUSH 0xffffffff
    // smallest computable:
    PUSH 0x100000000
    // Left shift:
    PUSH 0x8000000000000
    PUSH 0x400000000000000000000000000000000000000000000
    PUSH 0x8000000000000000000000000000000000000000000000000000000000000000
    PUSH 0x20a1c0fc00000000000000000000000000000000000000000000000000000000
    // not:
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8ad0
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
    PUSH 0xffffffffffffffffffffffffffffffffffffffff00000000ffffffffffffffff
    // PUSH0 NOT shift right:
    PUSH 0x3ffffffff
    PUSH 0x3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    // PUSH0 NOT shift right then left:
    PUSH 0x1fffffffffffffffe0000000000000000000000000000000000000000000
    PUSH 0x7ffffffffffffff0000000000000000
    // or:
    PUSH 0x1000000000000000030000000000000000000000000000000000000000000
    PUSH 0x100000000001000000000000100000000000
    PUSH 0xfffffffffffffffffffffffdffffffff0000000000000000ffffffffffffffff
    PUSH 0xffffffffffffffffffffffff00000000ffffffffffffffffffffffff00000000
    PUSH 0x77abc0000000000000000000000000000000000000000000000000000000001
    // sub:
    PUSH 0x3fffffffffffffffc0
    PUSH 0xffffffffffffffe0
// ====
// optimizationPreset: none
// optimizer.constantOptimizer: true
// optimizer.expectedExecutionsPerDeployment: 2000000
// outputs: Assembly
// ----
// Assembly:
//   0x02
// stop
//
// sub_0: assembly {
//       0x01
//       0x01
//       0x11f3d2be
//       0xffffffff
//       0x0100000000
//       0x08000000000000
//       0x0400000000000000000000000000000000000000000000
//       0x8000000000000000000000000000000000000000000000000000000000000000
//       0x20a1c0fc00000000000000000000000000000000000000000000000000000000
//       0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
//       0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8ad0
//       0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
//       0xffffffffffffffffffffffffffffffffffffffff00000000ffffffffffffffff
//       0x03ffffffff
//       0x03ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
//       0x1fffffffffffffffe0000000000000000000000000000000000000000000
//       0x07ffffffffffffff0000000000000000
//       0x01000000000000000030000000000000000000000000000000000000000000
//       0x100000000001000000000000100000000000
//       0xfffffffffffffffffffffffdffffffff0000000000000000ffffffffffffffff
//       0xffffffffffffffffffffffff00000000ffffffffffffffffffffffff00000000
//       0x077abc0000000000000000000000000000000000000000000000000000000001
//       0x3fffffffffffffffc0
//       0xffffffffffffffe0
// }
