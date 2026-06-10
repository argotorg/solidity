
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
// optimizer.expectedExecutionsPerDeployment: 0
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
//       shl(0x20, 0x01)
//       shl(0x33, 0x01)
//       shl(0xb2, 0x01)
//       shl(0xff, 0x01)
//       shl(0xe2, 0x0828703f)
//       not(0x00)
//       not(0x752f)
//       not(0xffffffff)
//       not(shl(0x40, 0xffffffff))
//       0x03ffffffff
//       sub(shl(0xfa, 0x01), 0x01)
//       sub(shl(0xed, 0x01), shl(0xad, 0x01))
//       sub(shl(0x7b, 0x01), shl(0x40, 0x01))
//       add(shl(0xf0, 0x01), shl(0xac, 0x03))
//       add(shl(0x60, 0x100000000001), shl(0x2c, 0x01))
//       not(sub(shl(0x80, 0x0200000001), shl(0x40, 0x01)))
//       not(add(shl(0x80, 0xffffffff), 0xffffffff))
//       add(shl(0xea, 0x01deaf), 0x01)
//       sub(shl(0x46, 0x01), 0x40)
//       sub(shl(0x40, 0x01), 0x20)
// }
