// Function arguments share one definition site. The entry stack is fixed in reverse argument order, and stores
// are therefore planned from arg0 at the top downward. With 34 live arguments, the last spilled argument is deep
// enough that its trace reloads an earlier, initialized sibling after dropping it.
object "C" {
    code {
        let g := memoryguard(0x80)
        mstore(0x40, g)
        f(
            calldataload(0x0), calldataload(0x20), calldataload(0x40), calldataload(0x60),
            calldataload(0x80), calldataload(0xa0), calldataload(0xc0), calldataload(0xe0),
            calldataload(0x100), calldataload(0x120), calldataload(0x140), calldataload(0x160),
            calldataload(0x180), calldataload(0x1a0), calldataload(0x1c0), calldataload(0x1e0),
            calldataload(0x200), calldataload(0x220), calldataload(0x240), calldataload(0x260),
            calldataload(0x280), calldataload(0x2a0), calldataload(0x2c0), calldataload(0x2e0),
            calldataload(0x300), calldataload(0x320), calldataload(0x340), calldataload(0x360),
            calldataload(0x380), calldataload(0x3a0), calldataload(0x3c0), calldataload(0x3e0),
            calldataload(0x400), calldataload(0x420)
        )
        function f(b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, b32, b33, b34) {
            sstore(0, b34)
            sstore(1, b33)
            sstore(2, b32)
            sstore(3, b31)
            sstore(4, b30)
            sstore(5, b29)
            sstore(6, b28)
            sstore(7, b27)
            sstore(8, b26)
            sstore(9, b25)
            sstore(10, b24)
            sstore(11, b23)
            sstore(12, b22)
            sstore(13, b21)
            sstore(14, b20)
            sstore(15, b19)
            sstore(16, b18)
            sstore(17, b17)
            sstore(18, b16)
            sstore(19, b15)
            sstore(20, b14)
            sstore(21, b13)
            sstore(22, b12)
            sstore(23, b11)
            sstore(24, b10)
            sstore(25, b9)
            sstore(26, b8)
            sstore(27, b7)
            sstore(28, b6)
            sstore(29, b5)
            sstore(30, b4)
            sstore(31, b3)
            sstore(32, b2)
            sstore(33, b1)
        }
    }
}
// ----
// object "C"
// ===== SSA CFG =====
// memoryguard = 0x04e0
//
// #0:
//     v0 = memoryguard
//     v1 = const 0x40
//     builtin @mstore v1, v0
//     v3 = const 0x0420
//     v4 = builtin @calldataload v3
//     v5 = const 0x0400
//     v6 = builtin @calldataload v5
//     v7 = const 0x03e0
//     v8 = builtin @calldataload v7
//     v9 = const 0x03c0
//     v10 = builtin @calldataload v9
//     v11 = const 0x03a0
//     v12 = builtin @calldataload v11
//     v13 = const 0x0380
//     v14 = builtin @calldataload v13
//     v15 = const 0x0360
//     v16 = builtin @calldataload v15
//     v17 = const 0x0340
//     v18 = builtin @calldataload v17
//     v19 = const 0x0320
//     v20 = builtin @calldataload v19
//     v21 = const 0x0300
//     v22 = builtin @calldataload v21
//     v23 = const 0x02e0
//     v24 = builtin @calldataload v23
//     v25 = const 0x02c0
//     v26 = builtin @calldataload v25
//     v27 = const 0x02a0
//     v28 = builtin @calldataload v27
//     v29 = const 0x0280
//     v30 = builtin @calldataload v29
//     v31 = const 0x0260
//     v32 = builtin @calldataload v31
//     v33 = const 0x0240
//     v34 = builtin @calldataload v33
//     v35 = const 0x0220
//     v36 = builtin @calldataload v35
//     v37 = const 0x0200
//     v38 = builtin @calldataload v37
//     v39 = const 0x01e0
//     v40 = builtin @calldataload v39
//     v41 = const 0x01c0
//     v42 = builtin @calldataload v41
//     v43 = const 0x01a0
//     v44 = builtin @calldataload v43
//     v45 = const 0x0180
//     v46 = builtin @calldataload v45
//     v47 = const 0x0160
//     v48 = builtin @calldataload v47
//     v49 = const 0x0140
//     v50 = builtin @calldataload v49
//     v51 = const 0x0120
//     v52 = builtin @calldataload v51
//     v53 = const 0x0100
//     v54 = builtin @calldataload v53
//     v55 = const 0xe0
//     v56 = builtin @calldataload v55
//     v57 = const 0xc0
//     v58 = builtin @calldataload v57
//     v59 = const 0xa0
//     v60 = builtin @calldataload v59
//     v61 = const 0x80
//     v62 = builtin @calldataload v61
//     v63 = const 0x60
//     v64 = builtin @calldataload v63
//     v65 = builtin @calldataload v1
//     v66 = const 0x20
//     v67 = builtin @calldataload v66
//     v68 = const 0x00
//     v69 = builtin @calldataload v68
//     call @f v69, v67, v65, v64, v62, v60, v58, v56, v54, v52, v50, v48, v46, v44, v42, v40, v38, v36, v34, v32, v30, v28, v26, v24, v22, v20, v18, v16, v14, v12, v10, v8, v6, v4
//     main_exit
//
// func @f(args: (v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33)) -> 0 {
// #0:
//     v0 = arg 0
//     v1 = arg 1
//     v2 = arg 2
//     v3 = arg 3
//     v4 = arg 4
//     v5 = arg 5
//     v6 = arg 6
//     v7 = arg 7
//     v8 = arg 8
//     v9 = arg 9
//     v10 = arg 10
//     v11 = arg 11
//     v12 = arg 12
//     v13 = arg 13
//     v14 = arg 14
//     v15 = arg 15
//     v16 = arg 16
//     v17 = arg 17
//     v18 = arg 18
//     v19 = arg 19
//     v20 = arg 20
//     v21 = arg 21
//     v22 = arg 22
//     v23 = arg 23
//     v24 = arg 24
//     v25 = arg 25
//     v26 = arg 26
//     v27 = arg 27
//     v28 = arg 28
//     v29 = arg 29
//     v30 = arg 30
//     v31 = arg 31
//     v32 = arg 32
//     v33 = arg 33
//     v34 = const 0x00
//     builtin @sstore v34, v33
//     v36 = const 0x01
//     builtin @sstore v36, v32
//     v38 = const 0x02
//     builtin @sstore v38, v31
//     v40 = const 0x03
//     builtin @sstore v40, v30
//     v42 = const 0x04
//     builtin @sstore v42, v29
//     v44 = const 0x05
//     builtin @sstore v44, v28
//     v46 = const 0x06
//     builtin @sstore v46, v27
//     v48 = const 0x07
//     builtin @sstore v48, v26
//     v50 = const 0x08
//     builtin @sstore v50, v25
//     v52 = const 0x09
//     builtin @sstore v52, v24
//     v54 = const 0x0a
//     builtin @sstore v54, v23
//     v56 = const 0x0b
//     builtin @sstore v56, v22
//     v58 = const 0x0c
//     builtin @sstore v58, v21
//     v60 = const 0x0d
//     builtin @sstore v60, v20
//     v62 = const 0x0e
//     builtin @sstore v62, v19
//     v64 = const 0x0f
//     builtin @sstore v64, v18
//     v66 = const 0x10
//     builtin @sstore v66, v17
//     v68 = const 0x11
//     builtin @sstore v68, v16
//     v70 = const 0x12
//     builtin @sstore v70, v15
//     v72 = const 0x13
//     builtin @sstore v72, v14
//     v74 = const 0x14
//     builtin @sstore v74, v13
//     v76 = const 0x15
//     builtin @sstore v76, v12
//     v78 = const 0x16
//     builtin @sstore v78, v11
//     v80 = const 0x17
//     builtin @sstore v80, v10
//     v82 = const 0x18
//     builtin @sstore v82, v9
//     v84 = const 0x19
//     builtin @sstore v84, v8
//     v86 = const 0x1a
//     builtin @sstore v86, v7
//     v88 = const 0x1b
//     builtin @sstore v88, v6
//     v90 = const 0x1c
//     builtin @sstore v90, v5
//     v92 = const 0x1d
//     builtin @sstore v92, v4
//     v94 = const 0x1e
//     builtin @sstore v94, v3
//     v96 = const 0x1f
//     builtin @sstore v96, v2
//     v98 = const 0x20
//     builtin @sstore v98, v1
//     v100 = const 0x21
//     builtin @sstore v100, v0
//     return
// }
//
// ===== spill info =====
// CFG[0] <main>
//   spilled:
//     v34 (value) -> mem 0x80
//     v38 (value) -> mem 0xa0
//     v40 (value) -> mem 0xc0
//     v42 (value) -> mem 0xe0
//     v44 (value) -> mem 0x0100
//     v46 (value) -> mem 0x0120
//     v48 (value) -> mem 0x0140
//     v50 (value) -> mem 0x0160
//     v52 (value) -> mem 0x0180
//     v54 (value) -> mem 0x01a0
//     v56 (value) -> mem 0x01c0
//     v58 (value) -> mem 0x01e0
//     v60 (value) -> mem 0x0200
//     v62 (value) -> mem 0x0220
//     v64 (value) -> mem 0x0240
//     v65 (value) -> mem 0x0260
//     v67 (value) -> mem 0x0280
//     v69 (value) -> mem 0x02a0
//   mstore schedule:
//     after v34 (B#0):
//       mstore addr(v34) <- v34 via [DUP1, STORE v34]
//     after v38 (B#0):
//       mstore addr(v38) <- v38 via [DUP1, STORE v38]
//     after v40 (B#0):
//       mstore addr(v40) <- v40 via [DUP1, STORE v40]
//     after v42 (B#0):
//       mstore addr(v42) <- v42 via [DUP1, STORE v42]
//     after v44 (B#0):
//       mstore addr(v44) <- v44 via [DUP1, STORE v44]
//     after v46 (B#0):
//       mstore addr(v46) <- v46 via [DUP1, STORE v46]
//     after v48 (B#0):
//       mstore addr(v48) <- v48 via [DUP1, STORE v48]
//     after v50 (B#0):
//       mstore addr(v50) <- v50 via [DUP1, STORE v50]
//     after v52 (B#0):
//       mstore addr(v52) <- v52 via [DUP1, STORE v52]
//     after v54 (B#0):
//       mstore addr(v54) <- v54 via [DUP1, STORE v54]
//     after v56 (B#0):
//       mstore addr(v56) <- v56 via [DUP1, STORE v56]
//     after v58 (B#0):
//       mstore addr(v58) <- v58 via [DUP1, STORE v58]
//     after v60 (B#0):
//       mstore addr(v60) <- v60 via [DUP1, STORE v60]
//     after v62 (B#0):
//       mstore addr(v62) <- v62 via [DUP1, STORE v62]
//     after v64 (B#0):
//       mstore addr(v64) <- v64 via [DUP1, STORE v64]
//     after v65 (B#0):
//       mstore addr(v65) <- v65 via [DUP1, STORE v65]
//     after v67 (B#0):
//       mstore addr(v67) <- v67 via [DUP1, STORE v67]
//     after v69 (B#0):
//       mstore addr(v69) <- v69 via [DUP1, STORE v69]
// CFG[1] f
//   spilled:
//     v1 (value) -> mem 0x02c0
//     v2 (value) -> mem 0x02e0
//     v3 (value) -> mem 0x0300
//     v4 (value) -> mem 0x0320
//     v5 (value) -> mem 0x0340
//     v6 (value) -> mem 0x0360
//     v7 (value) -> mem 0x0380
//     v8 (value) -> mem 0x03a0
//     v9 (value) -> mem 0x03c0
//     v10 (value) -> mem 0x03e0
//     v11 (value) -> mem 0x0400
//     v12 (value) -> mem 0x0420
//     v13 (value) -> mem 0x0440
//     v14 (value) -> mem 0x0460
//     v15 (value) -> mem 0x0480
//     v16 (value) -> mem 0x04a0
//     v17 (value) -> mem 0x04c0
//   mstore schedule:
//     function entry:
//       mstore addr(v1) <- v1 via [DUP2, STORE v1]
//       mstore addr(v2) <- v2 via [DUP3, STORE v2]
//       mstore addr(v3) <- v3 via [DUP4, STORE v3]
//       mstore addr(v4) <- v4 via [DUP5, STORE v4]
//       mstore addr(v5) <- v5 via [DUP6, STORE v5]
//       mstore addr(v6) <- v6 via [DUP7, STORE v6]
//       mstore addr(v7) <- v7 via [DUP8, STORE v7]
//       mstore addr(v8) <- v8 via [DUP9, STORE v8]
//       mstore addr(v9) <- v9 via [DUP10, STORE v9]
//       mstore addr(v10) <- v10 via [DUP11, STORE v10]
//       mstore addr(v11) <- v11 via [DUP12, STORE v11]
//       mstore addr(v12) <- v12 via [DUP13, STORE v12]
//       mstore addr(v13) <- v13 via [DUP14, STORE v13]
//       mstore addr(v14) <- v14 via [DUP15, STORE v14]
//       mstore addr(v15) <- v15 via [DUP16, STORE v15]
//       mstore addr(v16) <- v16 via [SWAP1, POP, DUP16, LOAD v1, SWAP2, SWAP1, STORE v16]
//       mstore addr(v17) <- v17 via [SWAP2, POP, POP, DUP16, LOAD v2, SWAP2, LOAD v1, SWAP2, STORE v17]
