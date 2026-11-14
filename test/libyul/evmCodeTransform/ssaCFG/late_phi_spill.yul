// The phi of `i` is created behind the `add` of the loop condition, and it is spilled, as is the argument `b1`:
// `b1` is stored once on entry of `f`, the phi on entry of the loop header.
object "C" {
    code {
        let g := memoryguard(0x80)
        mstore(0x40, g)
        f(calldataload(0x0), calldataload(0x20), calldataload(0x40), calldataload(0x60), calldataload(0x80), calldataload(0xa0), calldataload(0xc0), calldataload(0xe0), calldataload(0x100), calldataload(0x120), calldataload(0x140), calldataload(0x160), calldataload(0x180), calldataload(0x1a0), calldataload(0x1c0), calldataload(0x1e0), calldataload(0x200))
        function f(b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17) {
            for { let i := 0 } lt(i, add(b1, b2)) { i := add(i, 1) } {
                sstore(i, b17)
                sstore(b3, b4)
                sstore(b5, b6)
                sstore(b7, b8)
                sstore(b9, b10)
                sstore(b11, b12)
                sstore(b13, b14)
                sstore(b15, b16)
            }
        }
    }
}
// ====
// EVMVersion: =current
// stackOptimization: true
// viaSSACFG: true
// ----
// tag_2:
//   mstore(0x40, 0xe0)
//   calldataload(0x0200)
//   calldataload(0x01e0)
//   calldataload(0x01c0)
//   calldataload(0x01a0)
//   calldataload(0x0180)
//   calldataload(0x0160)
//   calldataload(0x0140)
//   calldataload(0x0120)
//   calldataload(0x0100)
//   calldataload(0xe0)
//   calldataload(0xc0)
//   calldataload(0xa0)
//   calldataload(0x80)
//   calldataload(0x60)
//   calldataload(0x40)
//   calldataload(0x20)
//   dup1
//   0x80
//   mstore
//   calldataload(0x00)
//   swap1
//   pop
//   swap15
//   swap14
//   swap13
//   swap12
//   swap11
//   swap10
//   swap9
//   swap8
//   swap7
//   swap6
//   swap5
//   swap4
//   swap3
//   swap2
//   swap1
//   tag_3
//   swap16
//   mload(0x80)
//   swap1
//   tag_1
//   jump	// in
// tag_3:
//   stop
// tag_1:
// tag_4:
//   dup1
//   0xa0
//   mstore
//   0x00
//   jump(tag_5)
// tag_5:
//   dup1
//   0xc0
//   mstore
//   swap1
//   dup3
//   swap1
//   add
//   swap1
//   lt
//   tag_6
//   jumpi
//   jump(tag_8)
// tag_8:
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   pop
//   jump	// out
// tag_6:
//   dup16
//   mload(0xc0)
//   sstore
//   dup3
//   dup3
//   sstore
//   dup5
//   dup5
//   sstore
//   dup7
//   dup7
//   sstore
//   dup9
//   dup9
//   sstore
//   dup11
//   dup11
//   sstore
//   dup13
//   dup13
//   sstore
//   dup15
//   dup15
//   sstore
//   add(mload(0xc0), 0x01)
//   mload(0xa0)
//   swap1
//   jump(tag_5)
