
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
    // PUSH0 NOT shift left:
    PUSH 0xffffffffffffffffffffffffffff000000000000000000000000000000000000
    PUSH 0xffffff0000000000000000000000000000000000000000000000000000000000
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
//       shl(0x20, not(0x00))
//       not(shl(0x40, 0xffffffff))
//       shr(0xde, not(0x00))
//       shr(0x06, not(0x00))
//       shl(0x90, not(0x00))
//       shl(0xe8, not(0x00))
//       shl(0xad, shr(0xc0, not(0x00)))
//       shl(0x40, shr(0xc5, not(0x00)))
//       shl(0xac, or(0x03, shl(0x44, 0x01)))
//       shl(0x2c, or(0x01, shl(0x34, 0x100000000001)))
//       not(shl(0x40, or(shr(0xc0, not(0x00)), shl(0x61, 0x01))))
//       or(shl(0x20, shr(0xa0, not(0x00))), shl(0xa0, not(0x00)))
//       or(0x01, shl(0xea, 0x01deaf))
//       sub(shl(0x46, 0x01), 0x40)
//       sub(shl(0x40, 0x01), 0x20)
// }
