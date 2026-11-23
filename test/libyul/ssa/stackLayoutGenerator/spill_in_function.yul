{
    function f() {
        // Many simultaneously-live locals inside a function with a return label
        // also pinning a stack slot — the layout generator must spill.
        let x01 := calldataload(0x01)
        let x02 := calldataload(0x02)
        let x03 := calldataload(0x03)
        let x04 := calldataload(0x04)
        let x05 := calldataload(0x05)
        let x06 := calldataload(0x06)
        let x07 := calldataload(0x07)
        let x08 := calldataload(0x08)
        let x09 := calldataload(0x09)
        let x10 := calldataload(0x0a)
        let x11 := calldataload(0x0b)
        let x12 := calldataload(0x0c)
        let x13 := calldataload(0x0d)
        let x14 := calldataload(0x0e)
        let x15 := calldataload(0x0f)
        let x16 := calldataload(0x10)
        let x17 := calldataload(0x11)
        let x18 := calldataload(0x12)
        sstore(x01, x18)
        sstore(x02, x17)
        sstore(x03, x16)
        sstore(x04, x15)
        sstore(x05, x14)
        sstore(x06, x13)
        sstore(x07, x12)
        sstore(x08, x11)
        sstore(x09, x10)
    }
    f()
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     ; [FunctionCallReturnLabel[0]]
//     call @f
//     ; out: []
//     main_exit
//
// func @f(args: ()) -> 0 {
//     ; spilled: {v35}
// #0:
//     ; in: [ReturnLabel[1]]
//     v0 = const 0x01
//     ; [ReturnLabel[1], lit0]
//     v1 = builtin @calldataload v0
//     v2 = const 0x02
//     ; [ReturnLabel[1], v1, lit2]
//     v3 = builtin @calldataload v2
//     v4 = const 0x03
//     ; [ReturnLabel[1], v1, v3, lit4]
//     v5 = builtin @calldataload v4
//     v6 = const 0x04
//     ; [ReturnLabel[1], v1, v3, v5, lit6]
//     v7 = builtin @calldataload v6
//     v8 = const 0x05
//     ; [ReturnLabel[1], v1, v3, v5, v7, lit8]
//     v9 = builtin @calldataload v8
//     v10 = const 0x06
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, lit10]
//     v11 = builtin @calldataload v10
//     v12 = const 0x07
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, lit12]
//     v13 = builtin @calldataload v12
//     v14 = const 0x08
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, lit14]
//     v15 = builtin @calldataload v14
//     v16 = const 0x09
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, lit16]
//     v17 = builtin @calldataload v16
//     v18 = const 0x0a
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, lit18]
//     v19 = builtin @calldataload v18
//     v20 = const 0x0b
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, lit20]
//     v21 = builtin @calldataload v20
//     v22 = const 0x0c
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, lit22]
//     v23 = builtin @calldataload v22
//     v24 = const 0x0d
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, lit24]
//     v25 = builtin @calldataload v24
//     v26 = const 0x0e
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, lit26]
//     v27 = builtin @calldataload v26
//     v28 = const 0x0f
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, lit28]
//     v29 = builtin @calldataload v28
//     v30 = const 0x10
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, lit30]
//     v31 = builtin @calldataload v30
//     v32 = const 0x11
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, lit32]
//     v33 = builtin @calldataload v32
//     v34 = const 0x12
//     ; [ReturnLabel[1], v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, v33, lit34]
//     v35 = builtin @calldataload v34
//     ; [ReturnLabel[1], v33, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, v35, v1]
//     builtin @sstore v1, v35
//     ; [ReturnLabel[1], v31, v29, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v33, v3]
//     builtin @sstore v3, v33
//     ; [ReturnLabel[1], v27, v29, v25, v7, v9, v11, v13, v15, v17, v19, v21, v23, v31, v5]
//     builtin @sstore v5, v31
//     ; [ReturnLabel[1], v27, v23, v25, v21, v9, v11, v13, v15, v17, v19, v29, v7]
//     builtin @sstore v7, v29
//     ; [ReturnLabel[1], v19, v23, v25, v21, v17, v11, v13, v15, v27, v9]
//     builtin @sstore v9, v27
//     ; [ReturnLabel[1], v19, v23, v15, v21, v17, v13, v25, v11]
//     builtin @sstore v11, v25
//     ; [ReturnLabel[1], v19, v17, v15, v21, v23, v13]
//     builtin @sstore v13, v23
//     ; [ReturnLabel[1], v19, v17, v21, v15]
//     builtin @sstore v15, v21
//     ; [ReturnLabel[1], v19, v17]
//     builtin @sstore v17, v19
//     ; out: [ReturnLabel[1]]
//     return
// }
//
