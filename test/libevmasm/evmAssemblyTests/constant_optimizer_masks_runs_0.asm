
PUSH 0x2

.sub
    PUSH 0x1
    PUSH 0x1
    PUSH 0x2000000
    PUSH 0x8000000000000
    PUSH 0x10000000000000000000
    PUSH 0x40000000000000000000000000
    PUSH 0x80000000000000000000000000000000
    PUSH 0x200000000000000000000000000000000000000
    PUSH 0x400000000000000000000000000000000000000000000
    PUSH 0x1000000000000000000000000000000000000000000000000000
    PUSH 0x2000000000000000000000000000000000000000000000000000000000
    PUSH 0x8000000000000000000000000000000000000000000000000000000000000000
    // masks with 2 bits
    PUSH 0x3
    PUSH 0x6000000
    PUSH 0xc000000000000
    PUSH 0x30000000000000000000
    PUSH 0x60000000000000000000000000
    PUSH 0x180000000000000000000000000000000
    PUSH 0x300000000000000000000000000000000000000
    PUSH 0x600000000000000000000000000000000000000000000
    PUSH 0x1800000000000000000000000000000000000000000000000000
    PUSH 0x3000000000000000000000000000000000000000000000000000000000
    PUSH 0xc000000000000000000000000000000000000000000000000000000000000000
    // masks with 3 bits
    PUSH 0x7
    PUSH 0xe000000
    PUSH 0x1c000000000000
    PUSH 0x38000000000000000000
    PUSH 0xe0000000000000000000000000
    PUSH 0x1c0000000000000000000000000000000
    PUSH 0x380000000000000000000000000000000000000
    PUSH 0xe00000000000000000000000000000000000000000000
    PUSH 0x1c00000000000000000000000000000000000000000000000000
    PUSH 0x3800000000000000000000000000000000000000000000000000000000
    PUSH 0xe000000000000000000000000000000000000000000000000000000000000000
    // masks with 4 bits
    PUSH 0xf
    PUSH 0x1e000000
    PUSH 0x3c000000000000
    PUSH 0x78000000000000000000
    PUSH 0xf0000000000000000000000000
    PUSH 0x3c0000000000000000000000000000000
    PUSH 0x780000000000000000000000000000000000000
    PUSH 0xf00000000000000000000000000000000000000000000
    PUSH 0x1e00000000000000000000000000000000000000000000000000
    PUSH 0x3c00000000000000000000000000000000000000000000000000000000
    PUSH 0xf000000000000000000000000000000000000000000000000000000000000000
    // masks with 7 bits
    PUSH 0x7f
    PUSH 0x7f000000
    PUSH 0xfe000000000000
    PUSH 0x1fc000000000000000000
    PUSH 0x3f8000000000000000000000000
    PUSH 0x7f0000000000000000000000000000000
    PUSH 0xfe0000000000000000000000000000000000000
    PUSH 0x1fc0000000000000000000000000000000000000000000
    PUSH 0x3f80000000000000000000000000000000000000000000000000
    PUSH 0x7f00000000000000000000000000000000000000000000000000000000
    PUSH 0xfe00000000000000000000000000000000000000000000000000000000000000
    // masks with 8 bits
    PUSH 0xff
    PUSH 0xff000000
    PUSH 0x1fe000000000000
    PUSH 0x3fc000000000000000000
    PUSH 0x7f8000000000000000000000000
    PUSH 0xff0000000000000000000000000000000
    PUSH 0xff0000000000000000000000000000000000000
    PUSH 0x1fe0000000000000000000000000000000000000000000
    PUSH 0x3fc0000000000000000000000000000000000000000000000000
    PUSH 0x7f80000000000000000000000000000000000000000000000000000000
    PUSH 0xff00000000000000000000000000000000000000000000000000000000000000
    // masks with 16 bits
    PUSH 0xffff
    PUSH 0xffff000000
    PUSH 0xffff000000000000
    PUSH 0xffff000000000000000000
    PUSH 0xffff000000000000000000000000
    PUSH 0xffff000000000000000000000000000000
    PUSH 0xffff000000000000000000000000000000000000
    PUSH 0xffff000000000000000000000000000000000000000000
    PUSH 0xffff000000000000000000000000000000000000000000000000
    PUSH 0xffff000000000000000000000000000000000000000000000000000000
    PUSH 0xffff000000000000000000000000000000000000000000000000000000000000
    // masks with 23 bits
    PUSH 0x7fffff
    PUSH 0x3fffff800000
    PUSH 0x1fffffc00000000000
    PUSH 0xfffffe00000000000000000
    PUSH 0xfffffe00000000000000000000000
    PUSH 0x7fffff00000000000000000000000000000
    PUSH 0x3fffff80000000000000000000000000000000000
    PUSH 0x3fffff80000000000000000000000000000000000000000
    PUSH 0x1fffffc0000000000000000000000000000000000000000000000
    PUSH 0xfffffe0000000000000000000000000000000000000000000000000000
    PUSH 0xfffffe0000000000000000000000000000000000000000000000000000000000
    // masks with 32 bits
    PUSH 0xffffffff
    PUSH 0x3fffffffc00000
    PUSH 0xffffffff00000000000
    PUSH 0x7fffffff80000000000000000
    PUSH 0x1fffffffe0000000000000000000000
    PUSH 0xffffffff0000000000000000000000000000
    PUSH 0x3fffffffc000000000000000000000000000000000
    PUSH 0xffffffff000000000000000000000000000000000000000
    PUSH 0x7fffffff800000000000000000000000000000000000000000000
    PUSH 0x1fffffffe00000000000000000000000000000000000000000000000000
    PUSH 0xffffffff00000000000000000000000000000000000000000000000000000000
    // masks with 47 bits
    PUSH 0x7fffffffffff
    PUSH 0x7fffffffffff00000
    PUSH 0xfffffffffffe0000000000
    PUSH 0x1fffffffffffc000000000000000
    PUSH 0x3fffffffffff800000000000000000000
    PUSH 0x7fffffffffff00000000000000000000000000
    PUSH 0xfffffffffffe0000000000000000000000000000000
    PUSH 0x1fffffffffffc000000000000000000000000000000000000
    PUSH 0x3fffffffffff800000000000000000000000000000000000000000
    PUSH 0x7fffffffffff00000000000000000000000000000000000000000000000
    PUSH 0xfffffffffffe0000000000000000000000000000000000000000000000000000
    // masks with 64 bits
    PUSH 0xffffffffffffffff
    PUSH 0x7fffffffffffffff80000
    PUSH 0x3fffffffffffffffc000000000
    PUSH 0x1fffffffffffffffe00000000000000
    PUSH 0xffffffffffffffff0000000000000000000
    PUSH 0xffffffffffffffff000000000000000000000000
    PUSH 0x7fffffffffffffff80000000000000000000000000000
    PUSH 0x3fffffffffffffffc000000000000000000000000000000000
    PUSH 0x1fffffffffffffffe00000000000000000000000000000000000000
    PUSH 0xffffffffffffffff0000000000000000000000000000000000000000000
    PUSH 0xffffffffffffffff000000000000000000000000000000000000000000000000
    // masks with 92 bits
    PUSH 0xfffffffffffffffffffffff
    PUSH 0xfffffffffffffffffffffff0000
    PUSH 0xfffffffffffffffffffffff00000000
    PUSH 0x1ffffffffffffffffffffffe000000000000
    PUSH 0x1ffffffffffffffffffffffe0000000000000000
    PUSH 0x3ffffffffffffffffffffffc00000000000000000000
    PUSH 0x3ffffffffffffffffffffffc000000000000000000000000
    PUSH 0x3ffffffffffffffffffffffc0000000000000000000000000000
    PUSH 0x7ffffffffffffffffffffff800000000000000000000000000000000
    PUSH 0x7ffffffffffffffffffffff8000000000000000000000000000000000000
    PUSH 0xfffffffffffffffffffffff00000000000000000000000000000000000000000
    // masks with 103 bits
    PUSH 0x7fffffffffffffffffffffffff
    PUSH 0x3fffffffffffffffffffffffff8000
    PUSH 0x1fffffffffffffffffffffffffc0000000
    PUSH 0xfffffffffffffffffffffffffe00000000000
    PUSH 0xfffffffffffffffffffffffffe000000000000000
    PUSH 0x7fffffffffffffffffffffffff0000000000000000000
    PUSH 0x3fffffffffffffffffffffffff80000000000000000000000
    PUSH 0x3fffffffffffffffffffffffff800000000000000000000000000
    PUSH 0x1fffffffffffffffffffffffffc000000000000000000000000000000
    PUSH 0xfffffffffffffffffffffffffe0000000000000000000000000000000000
    PUSH 0xfffffffffffffffffffffffffe00000000000000000000000000000000000000
    // masks with 128 bits
    PUSH 0xffffffffffffffffffffffffffffffff
    PUSH 0xffffffffffffffffffffffffffffffff000
    PUSH 0x1fffffffffffffffffffffffffffffffe000000
    PUSH 0x3fffffffffffffffffffffffffffffffc000000000
    PUSH 0x7fffffffffffffffffffffffffffffff8000000000000
    PUSH 0xffffffffffffffffffffffffffffffff0000000000000000
    PUSH 0xffffffffffffffffffffffffffffffff0000000000000000000
    PUSH 0x1fffffffffffffffffffffffffffffffe0000000000000000000000
    PUSH 0x3fffffffffffffffffffffffffffffffc0000000000000000000000000
    PUSH 0x7fffffffffffffffffffffffffffffff80000000000000000000000000000
    PUSH 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000
    // masks with 133 bits
    PUSH 0x1fffffffffffffffffffffffffffffffff
    PUSH 0x1fffffffffffffffffffffffffffffffff000
    PUSH 0x1fffffffffffffffffffffffffffffffff000000
    PUSH 0x1fffffffffffffffffffffffffffffffff000000000
    PUSH 0x3ffffffffffffffffffffffffffffffffe000000000000
    PUSH 0x3ffffffffffffffffffffffffffffffffe000000000000000
    PUSH 0x3ffffffffffffffffffffffffffffffffe000000000000000000
    PUSH 0x7ffffffffffffffffffffffffffffffffc000000000000000000000
    PUSH 0x7ffffffffffffffffffffffffffffffffc000000000000000000000000
    PUSH 0x7ffffffffffffffffffffffffffffffffc000000000000000000000000000
    PUSH 0xfffffffffffffffffffffffffffffffff8000000000000000000000000000000
    // masks with 160 bits
    PUSH 0xffffffffffffffffffffffffffffffffffffffff
    PUSH 0x1fffffffffffffffffffffffffffffffffffffffe00
    PUSH 0x7fffffffffffffffffffffffffffffffffffffff80000
    PUSH 0xffffffffffffffffffffffffffffffffffffffff0000000
    PUSH 0x3fffffffffffffffffffffffffffffffffffffffc000000000
    PUSH 0xffffffffffffffffffffffffffffffffffffffff000000000000
    PUSH 0x1fffffffffffffffffffffffffffffffffffffffe00000000000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffff80000000000000000
    PUSH 0xffffffffffffffffffffffffffffffffffffffff0000000000000000000
    PUSH 0x3fffffffffffffffffffffffffffffffffffffffc000000000000000000000
    PUSH 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000
    // masks with 175 bits
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff00
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff0000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff00000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff0000000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff000000000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff00000000000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff0000000000000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffff000000000000000000
    PUSH 0xfffffffffffffffffffffffffffffffffffffffffffe00000000000000000000
    // masks with 200 bits
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffff
    PUSH 0x1fffffffffffffffffffffffffffffffffffffffffffffffffe0
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffffffffff800
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffff0000
    PUSH 0x3fffffffffffffffffffffffffffffffffffffffffffffffffc00000
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffff0000000
    PUSH 0x1fffffffffffffffffffffffffffffffffffffffffffffffffe00000000
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffffffffff8000000000
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffff00000000000
    PUSH 0x3fffffffffffffffffffffffffffffffffffffffffffffffffc000000000000
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000
    // masks with 255 bits
    PUSH 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    PUSH 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe
    // masks with 256 bits
    PUSH 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
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
//       0x02000000
//       shl(0x33, 0x01)
//       shl(0x4c, 0x01)
//       shl(0x66, 0x01)
//       shl(0x7f, 0x01)
//       shl(0x99, 0x01)
//       shl(0xb2, 0x01)
//       shl(0xcc, 0x01)
//       shl(0xe5, 0x01)
//       shl(0xff, 0x01)
//       0x03
//       0x06000000
//       shl(0x32, 0x03)
//       shl(0x4c, 0x03)
//       shl(0x65, 0x03)
//       shl(0x7f, 0x03)
//       shl(0x98, 0x03)
//       shl(0xb1, 0x03)
//       shl(0xcb, 0x03)
//       shl(0xe4, 0x03)
//       shl(0xfe, 0x03)
//       0x07
//       0x0e000000
//       shl(0x32, 0x07)
//       shl(0x4b, 0x07)
//       shl(0x65, 0x07)
//       shl(0x7e, 0x07)
//       shl(0x97, 0x07)
//       shl(0xb1, 0x07)
//       shl(0xca, 0x07)
//       shl(0xe3, 0x07)
//       shl(0xfd, 0x07)
//       0x0f
//       0x1e000000
//       shl(0x32, 0x0f)
//       shl(0x4b, 0x0f)
//       shl(0x64, 0x0f)
//       shl(0x7e, 0x0f)
//       shl(0x97, 0x0f)
//       shl(0xb0, 0x0f)
//       shl(0xc9, 0x0f)
//       shl(0xe2, 0x0f)
//       shl(0xfc, 0x0f)
//       0x7f
//       0x7f000000
//       shl(0x31, 0x7f)
//       shl(0x4a, 0x7f)
//       shl(0x63, 0x7f)
//       shl(0x7c, 0x7f)
//       shl(0x95, 0x7f)
//       shl(0xae, 0x7f)
//       shl(0xc7, 0x7f)
//       shl(0xe0, 0x7f)
//       shl(0xf9, 0x7f)
//       0xff
//       0xff000000
//       shl(0x31, 0xff)
//       shl(0x4a, 0xff)
//       shl(0x63, 0xff)
//       shl(0x7c, 0xff)
//       shl(0x94, 0xff)
//       shl(0xad, 0xff)
//       shl(0xc6, 0xff)
//       shl(0xdf, 0xff)
//       shl(0xf8, 0xff)
//       0xffff
//       0xffff000000
//       shl(0x30, 0xffff)
//       shl(0x48, 0xffff)
//       shl(0x60, 0xffff)
//       shl(0x78, 0xffff)
//       shl(0x90, 0xffff)
//       shl(0xa8, 0xffff)
//       shl(0xc0, 0xffff)
//       shl(0xd8, 0xffff)
//       shl(0xf0, 0xffff)
//       0x7fffff
//       0x3fffff800000
//       shl(0x2e, 0x7fffff)
//       shl(0x45, 0x7fffff)
//       shl(0x5d, 0x7fffff)
//       shl(0x74, 0x7fffff)
//       shl(0x8b, 0x7fffff)
//       shl(0xa3, 0x7fffff)
//       shl(0xba, 0x7fffff)
//       shl(0xd1, 0x7fffff)
//       not(shr(0x17, not(0x00)))
//       0xffffffff
//       0x3fffffffc00000
//       shl(0x2c, 0xffffffff)
//       shl(0x43, 0xffffffff)
//       shl(0x59, 0xffffffff)
//       shl(0x70, 0xffffffff)
//       shl(0x86, 0xffffffff)
//       shl(0x9c, 0xffffffff)
//       shl(0xb3, 0xffffffff)
//       shl(0xc9, 0xffffffff)
//       not(shr(0x20, not(0x00)))
//       shr(0xd1, not(0x00))
//       shl(0x14, shr(0xd1, not(0x00)))
//       shl(0x29, shr(0xd1, not(0x00)))
//       shl(0x3e, shr(0xd1, not(0x00)))
//       shl(0x53, shr(0xd1, not(0x00)))
//       shl(0x68, shr(0xd1, not(0x00)))
//       shl(0x7d, shr(0xd1, not(0x00)))
//       shl(0x92, shr(0xd1, not(0x00)))
//       shl(0xa7, shr(0xd1, not(0x00)))
//       shl(0xbc, shr(0xd1, not(0x00)))
//       shl(0xd1, not(0x00))
//       shr(0xc0, not(0x00))
//       shl(0x13, shr(0xc0, not(0x00)))
//       shl(0x26, shr(0xc0, not(0x00)))
//       shl(0x39, shr(0xc0, not(0x00)))
//       shl(0x4c, shr(0xc0, not(0x00)))
//       shl(0x60, shr(0xc0, not(0x00)))
//       shl(0x73, shr(0xc0, not(0x00)))
//       shl(0x86, shr(0xc0, not(0x00)))
//       shl(0x99, shr(0xc0, not(0x00)))
//       shl(0xac, shr(0xc0, not(0x00)))
//       shl(0xc0, not(0x00))
//       shr(0xa4, not(0x00))
//       shl(0x10, shr(0xa4, not(0x00)))
//       shl(0x20, shr(0xa4, not(0x00)))
//       shl(0x31, shr(0xa4, not(0x00)))
//       shl(0x41, shr(0xa4, not(0x00)))
//       shl(0x52, shr(0xa4, not(0x00)))
//       shl(0x62, shr(0xa4, not(0x00)))
//       shl(0x72, shr(0xa4, not(0x00)))
//       shl(0x83, shr(0xa4, not(0x00)))
//       shl(0x93, shr(0xa4, not(0x00)))
//       shl(0xa4, not(0x00))
//       shr(0x99, not(0x00))
//       shl(0x0f, shr(0x99, not(0x00)))
//       shl(0x1e, shr(0x99, not(0x00)))
//       shl(0x2d, shr(0x99, not(0x00)))
//       shl(0x3d, shr(0x99, not(0x00)))
//       shl(0x4c, shr(0x99, not(0x00)))
//       shl(0x5b, shr(0x99, not(0x00)))
//       shl(0x6b, shr(0x99, not(0x00)))
//       shl(0x7a, shr(0x99, not(0x00)))
//       shl(0x89, shr(0x99, not(0x00)))
//       shl(0x99, not(0x00))
//       shr(0x80, not(0x00))
//       shl(0x0c, shr(0x80, not(0x00)))
//       shl(0x19, shr(0x80, not(0x00)))
//       shl(0x26, shr(0x80, not(0x00)))
//       shl(0x33, shr(0x80, not(0x00)))
//       shl(0x40, shr(0x80, not(0x00)))
//       shl(0x4c, shr(0x80, not(0x00)))
//       shl(0x59, shr(0x80, not(0x00)))
//       shl(0x66, shr(0x80, not(0x00)))
//       shl(0x73, shr(0x80, not(0x00)))
//       shl(0x80, not(0x00))
//       shr(0x7b, not(0x00))
//       shl(0x0c, shr(0x7b, not(0x00)))
//       shl(0x18, shr(0x7b, not(0x00)))
//       shl(0x24, shr(0x7b, not(0x00)))
//       shl(0x31, shr(0x7b, not(0x00)))
//       shl(0x3d, shr(0x7b, not(0x00)))
//       shl(0x49, shr(0x7b, not(0x00)))
//       shl(0x56, shr(0x7b, not(0x00)))
//       shl(0x62, shr(0x7b, not(0x00)))
//       shl(0x6e, shr(0x7b, not(0x00)))
//       shl(0x7b, not(0x00))
//       shr(0x60, not(0x00))
//       shl(0x09, shr(0x60, not(0x00)))
//       shl(0x13, shr(0x60, not(0x00)))
//       shl(0x1c, shr(0x60, not(0x00)))
//       shl(0x26, shr(0x60, not(0x00)))
//       shl(0x30, shr(0x60, not(0x00)))
//       shl(0x39, shr(0x60, not(0x00)))
//       shl(0x43, shr(0x60, not(0x00)))
//       shl(0x4c, shr(0x60, not(0x00)))
//       shl(0x56, shr(0x60, not(0x00)))
//       shl(0x60, not(0x00))
//       shr(0x51, not(0x00))
//       shl(0x08, shr(0x51, not(0x00)))
//       shl(0x10, shr(0x51, not(0x00)))
//       shl(0x18, shr(0x51, not(0x00)))
//       shl(0x20, shr(0x51, not(0x00)))
//       shl(0x28, shr(0x51, not(0x00)))
//       shl(0x30, shr(0x51, not(0x00)))
//       shl(0x38, shr(0x51, not(0x00)))
//       shl(0x40, shr(0x51, not(0x00)))
//       shl(0x48, shr(0x51, not(0x00)))
//       shl(0x51, not(0x00))
//       shr(0x38, not(0x00))
//       shl(0x05, shr(0x38, not(0x00)))
//       shl(0x0b, shr(0x38, not(0x00)))
//       shl(0x10, shr(0x38, not(0x00)))
//       shl(0x16, shr(0x38, not(0x00)))
//       shl(0x1c, shr(0x38, not(0x00)))
//       shl(0x21, shr(0x38, not(0x00)))
//       shl(0x27, shr(0x38, not(0x00)))
//       shl(0x2c, shr(0x38, not(0x00)))
//       shl(0x32, shr(0x38, not(0x00)))
//       shl(0x38, not(0x00))
//       shr(0x01, not(0x00))
//       not(0x01)
//       not(0x00)
// }
