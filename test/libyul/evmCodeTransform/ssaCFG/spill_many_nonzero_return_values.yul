object "C" {
    code {
        mstore(0x40, memoryguard(0x120))
        function many() -> r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17 {
            r0 := 1
            r1 := 2
            r2 := 3
            r3 := 4
            r4 := 5
            r5 := 6
            r6 := 7
            r7 := 8
            r8 := 9
            r9 := 10
            r10 := 11
            r11 := 12
            r12 := 13
            r13 := 14
            r14 := 15
            r15 := 16
            r16 := 17
            r17 := 18
        }
        let v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17 := many()
        sstore(v0, v1)
        sstore(v2, v3)
        sstore(v4, v5)
        sstore(v6, v7)
        sstore(v8, v9)
        sstore(v10, v11)
        sstore(v12, v13)
        sstore(v14, v15)
        sstore(v16, v17)
    }
}
// ====
// EVMVersion: =current
// stackOptimization: true
// viaSSACFG: true
// ----
// tag_2:
//   mstore(0x40, 0x0160)
//   tag_3
//   tag_1
//   jump	// in
// tag_3:
//   dup1
//   0x0140
//   mstore
//   pop
//   dup16
//   mload(0x0140)
//   swap1
//   0x0120
//   mstore
//   pop
//   swap15
//   swap1
//   swap16
//   sstore
//   swap11
//   swap1
//   swap12
//   sstore
//   swap7
//   swap1
//   swap8
//   sstore
//   swap3
//   swap1
//   swap4
//   sstore
//   swap1
//   swap2
//   swap1
//   sstore
//   swap1
//   swap2
//   swap1
//   sstore
//   swap1
//   swap2
//   swap1
//   sstore
//   swap1
//   swap2
//   swap1
//   sstore
//   mload(0x0140)
//   swap1
//   sstore
//   stop
// tag_1:
// tag_4:
//   0x02
//   0x03
//   0x04
//   0x05
//   0x06
//   0x07
//   0x08
//   0x09
//   0x0a
//   0x0b
//   0x0c
//   0x0d
//   0x0e
//   0x0f
//   0x10
//   0x01
//   swap16
//   0x12
//   0x11
//   swap2
//   jump	// out
