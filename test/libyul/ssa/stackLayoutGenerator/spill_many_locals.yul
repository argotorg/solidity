{
    // All locals are live throughout and consumed in pairs from
    // opposite ends which forces the layout generator to spill some of them
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
    let x19 := calldataload(0x13)
    let x20 := calldataload(0x14)
    sstore(x01, x20)
    sstore(x02, x19)
    sstore(x03, x18)
    sstore(x04, x17)
    sstore(x05, x16)
    sstore(x06, x15)
    sstore(x07, x14)
    sstore(x08, x13)
    sstore(x09, x12)
    sstore(x10, x11)
}
// ----
// object "object"
//     ; spilled: {v33, v35, v39}
// #0:
//     ; in: []
//     v0 = const 0x01
//     ; [lit0]
//     v1 = builtin @calldataload v0
//     v2 = const 0x02
//     ; [v1, lit2]
//     v3 = builtin @calldataload v2
//     v4 = const 0x03
//     ; [v1, v3, lit4]
//     v5 = builtin @calldataload v4
//     v6 = const 0x04
//     ; [v1, v3, v5, lit6]
//     v7 = builtin @calldataload v6
//     v8 = const 0x05
//     ; [v1, v3, v5, v7, lit8]
//     v9 = builtin @calldataload v8
//     v10 = const 0x06
//     ; [v1, v3, v5, v7, v9, lit10]
//     v11 = builtin @calldataload v10
//     v12 = const 0x07
//     ; [v1, v3, v5, v7, v9, v11, lit12]
//     v13 = builtin @calldataload v12
//     v14 = const 0x08
//     ; [v1, v3, v5, v7, v9, v11, v13, lit14]
//     v15 = builtin @calldataload v14
//     v16 = const 0x09
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, lit16]
//     v17 = builtin @calldataload v16
//     v18 = const 0x0a
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, lit18]
//     v19 = builtin @calldataload v18
//     v20 = const 0x0b
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, lit20]
//     v21 = builtin @calldataload v20
//     v22 = const 0x0c
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, lit22]
//     v23 = builtin @calldataload v22
//     v24 = const 0x0d
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, lit24]
//     v25 = builtin @calldataload v24
//     v26 = const 0x0e
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, lit26]
//     v27 = builtin @calldataload v26
//     v28 = const 0x0f
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, lit28]
//     v29 = builtin @calldataload v28
//     v30 = const 0x10
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, lit30]
//     v31 = builtin @calldataload v30
//     v32 = const 0x11
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, lit32]
//     v33 = builtin @calldataload v32
//     v34 = const 0x12
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, v33, lit34]
//     v35 = builtin @calldataload v34
//     v36 = const 0x13
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, v33, v35, lit36]
//     v37 = builtin @calldataload v36
//     v38 = const 0x14
//     ; [v1, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, v33, v35, v37, lit38]
//     v39 = builtin @calldataload v38
//     ; [v37, v3, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v29, v31, v39, v1]
//     builtin @sstore v1, v39
//     ; [v31, v29, v5, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v27, v37, v3]
//     builtin @sstore v3, v37
//     ; [v31, v29, v27, v7, v9, v11, v13, v15, v17, v19, v21, v23, v25, v35, v5]
//     builtin @sstore v5, v35
//     ; [v31, v29, v27, v25, v9, v11, v13, v15, v17, v19, v21, v23, v33, v7]
//     builtin @sstore v7, v33
//     ; [v23, v29, v27, v25, v21, v11, v13, v15, v17, v19, v31, v9]
//     builtin @sstore v9, v31
//     ; [v23, v19, v27, v25, v21, v17, v13, v15, v29, v11]
//     builtin @sstore v11, v29
//     ; [v23, v19, v15, v25, v21, v17, v27, v13]
//     builtin @sstore v13, v27
//     ; [v23, v19, v21, v17, v25, v15]
//     builtin @sstore v15, v25
//     ; [v21, v19, v23, v17]
//     builtin @sstore v17, v23
//     ; [v21, v19]
//     builtin @sstore v19, v21
//     ; out: []
//     main_exit
//
