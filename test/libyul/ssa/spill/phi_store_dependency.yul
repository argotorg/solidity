// Thirty-three loop-carried values force seventeen phis to spill at one block entry. The old per-value planner
// stored them in InstId order, so the first trace dropped the highest sibling and loaded its uninitialized slot.
// Grouped planning must store the highest spilled phi first and may only load it in a later sibling's trace.
{
    mstore(0x40, memoryguard(0x80))
    let x0 := calldataload(0)
    let x1 := calldataload(32)
    let x2 := calldataload(64)
    let x3 := calldataload(96)
    let x4 := calldataload(128)
    let x5 := calldataload(160)
    let x6 := calldataload(192)
    let x7 := calldataload(224)
    let x8 := calldataload(256)
    let x9 := calldataload(288)
    let x10 := calldataload(320)
    let x11 := calldataload(352)
    let x12 := calldataload(384)
    let x13 := calldataload(416)
    let x14 := calldataload(448)
    let x15 := calldataload(480)
    let x16 := calldataload(512)
    let x17 := calldataload(544)
    let x18 := calldataload(576)
    let x19 := calldataload(608)
    let x20 := calldataload(640)
    let x21 := calldataload(672)
    let x22 := calldataload(704)
    let x23 := calldataload(736)
    let x24 := calldataload(768)
    let x25 := calldataload(800)
    let x26 := calldataload(832)
    let x27 := calldataload(864)
    let x28 := calldataload(896)
    let x29 := calldataload(928)
    let x30 := calldataload(960)
    let x31 := calldataload(992)
    let x32 := calldataload(1024)
    for {} lt(x0, 5) { x0 := add(x0, 1) } {
        x0 := add(x0, 1)
        x1 := add(x1, 2)
        x2 := add(x2, 3)
        x3 := add(x3, 4)
        x4 := add(x4, 5)
        x5 := add(x5, 6)
        x6 := add(x6, 7)
        x7 := add(x7, 8)
        x8 := add(x8, 9)
        x9 := add(x9, 10)
        x10 := add(x10, 11)
        x11 := add(x11, 12)
        x12 := add(x12, 13)
        x13 := add(x13, 14)
        x14 := add(x14, 15)
        x15 := add(x15, 16)
        x16 := add(x16, 17)
        x17 := add(x17, 18)
        x18 := add(x18, 19)
        x19 := add(x19, 20)
        x20 := add(x20, 21)
        x21 := add(x21, 22)
        x22 := add(x22, 23)
        x23 := add(x23, 24)
        x24 := add(x24, 25)
        x25 := add(x25, 26)
        x26 := add(x26, 27)
        x27 := add(x27, 28)
        x28 := add(x28, 29)
        x29 := add(x29, 30)
        x30 := add(x30, 31)
        x31 := add(x31, 32)
        x32 := add(x32, 33)
    }
    sstore(0, add(x0, x1))
    sstore(1, add(x2, x3))
    sstore(2, add(x4, x5))
    sstore(3, add(x6, x7))
    sstore(4, add(x8, x9))
    sstore(5, add(x10, x11))
    sstore(6, add(x12, x13))
    sstore(7, add(x14, x15))
    sstore(8, add(x16, x17))
    sstore(9, add(x18, x19))
    sstore(10, add(x20, x21))
    sstore(11, add(x22, x23))
    sstore(12, add(x24, x25))
    sstore(13, add(x26, x27))
    sstore(14, add(x28, x29))
    sstore(15, add(x30, x31))
    sstore(16, add(x32, x32))
}
// ----
// object "object"
// ===== SSA CFG =====
// memoryguard = 0x04a0
//
// #0:
//     v0 = memoryguard
//     v1 = const 0x40
//     builtin @mstore v1, v0
//     v3 = const 0x00
//     v4 = builtin @calldataload v3
//     v5 = const 0x20
//     v6 = builtin @calldataload v5
//     v7 = builtin @calldataload v1
//     v8 = const 0x60
//     v9 = builtin @calldataload v8
//     v10 = const 0x80
//     v11 = builtin @calldataload v10
//     v12 = const 0xa0
//     v13 = builtin @calldataload v12
//     v14 = const 0xc0
//     v15 = builtin @calldataload v14
//     v16 = const 0xe0
//     v17 = builtin @calldataload v16
//     v18 = const 0x0100
//     v19 = builtin @calldataload v18
//     v20 = const 0x0120
//     v21 = builtin @calldataload v20
//     v22 = const 0x0140
//     v23 = builtin @calldataload v22
//     v24 = const 0x0160
//     v25 = builtin @calldataload v24
//     v26 = const 0x0180
//     v27 = builtin @calldataload v26
//     v28 = const 0x01a0
//     v29 = builtin @calldataload v28
//     v30 = const 0x01c0
//     v31 = builtin @calldataload v30
//     v32 = const 0x01e0
//     v33 = builtin @calldataload v32
//     v34 = const 0x0200
//     v35 = builtin @calldataload v34
//     v36 = const 0x0220
//     v37 = builtin @calldataload v36
//     v38 = const 0x0240
//     v39 = builtin @calldataload v38
//     v40 = const 0x0260
//     v41 = builtin @calldataload v40
//     v42 = const 0x0280
//     v43 = builtin @calldataload v42
//     v44 = const 0x02a0
//     v45 = builtin @calldataload v44
//     v46 = const 0x02c0
//     v47 = builtin @calldataload v46
//     v48 = const 0x02e0
//     v49 = builtin @calldataload v48
//     v50 = const 0x0300
//     v51 = builtin @calldataload v50
//     v52 = const 0x0320
//     v53 = builtin @calldataload v52
//     v54 = const 0x0340
//     v55 = builtin @calldataload v54
//     v56 = const 0x0360
//     v57 = builtin @calldataload v56
//     v58 = const 0x0380
//     v59 = builtin @calldataload v58
//     v60 = const 0x03a0
//     v61 = builtin @calldataload v60
//     v62 = const 0x03c0
//     v63 = builtin @calldataload v62
//     v64 = const 0x03e0
//     v65 = builtin @calldataload v64
//     v66 = const 0x0400
//     v67 = builtin @calldataload v66
//     v68 = const 0x05
//     v71 = const 0x01
//     v73 = const 0x02
//     v76 = const 0x03
//     v79 = const 0x04
//     v84 = const 0x06
//     v87 = const 0x07
//     v90 = const 0x08
//     v93 = const 0x09
//     v96 = const 0x0a
//     v99 = const 0x0b
//     v102 = const 0x0c
//     v105 = const 0x0d
//     v108 = const 0x0e
//     v111 = const 0x0f
//     v114 = const 0x10
//     v117 = const 0x11
//     v120 = const 0x12
//     v123 = const 0x13
//     v126 = const 0x14
//     v129 = const 0x15
//     v132 = const 0x16
//     v135 = const 0x17
//     v138 = const 0x18
//     v141 = const 0x19
//     v144 = const 0x1a
//     v147 = const 0x1b
//     v150 = const 0x1c
//     v153 = const 0x1d
//     v156 = const 0x1e
//     v159 = const 0x1f
//     v164 = const 0x21
//     upsilon v4 -> ^v69
//     upsilon v6 -> ^v74
//     upsilon v7 -> ^v77
//     upsilon v9 -> ^v80
//     upsilon v11 -> ^v82
//     upsilon v13 -> ^v85
//     upsilon v15 -> ^v88
//     upsilon v17 -> ^v91
//     upsilon v19 -> ^v94
//     upsilon v21 -> ^v97
//     upsilon v23 -> ^v100
//     upsilon v25 -> ^v103
//     upsilon v27 -> ^v106
//     upsilon v29 -> ^v109
//     upsilon v31 -> ^v112
//     upsilon v33 -> ^v115
//     upsilon v35 -> ^v118
//     upsilon v37 -> ^v121
//     upsilon v39 -> ^v124
//     upsilon v41 -> ^v127
//     upsilon v43 -> ^v130
//     upsilon v45 -> ^v133
//     upsilon v47 -> ^v136
//     upsilon v49 -> ^v139
//     upsilon v51 -> ^v142
//     upsilon v53 -> ^v145
//     upsilon v55 -> ^v148
//     upsilon v57 -> ^v151
//     upsilon v59 -> ^v154
//     upsilon v61 -> ^v157
//     upsilon v63 -> ^v160
//     upsilon v65 -> ^v162
//     upsilon v67 -> ^v165
//     jump #1
// #1: preds: #0, #2
//     v69 = phi
//     v70 = builtin @lt v69, v68
//     v74 = phi
//     v77 = phi
//     v80 = phi
//     v82 = phi
//     v85 = phi
//     v88 = phi
//     v91 = phi
//     v94 = phi
//     v97 = phi
//     v100 = phi
//     v103 = phi
//     v106 = phi
//     v109 = phi
//     v112 = phi
//     v115 = phi
//     v118 = phi
//     v121 = phi
//     v124 = phi
//     v127 = phi
//     v130 = phi
//     v133 = phi
//     v136 = phi
//     v139 = phi
//     v142 = phi
//     v145 = phi
//     v148 = phi
//     v151 = phi
//     v154 = phi
//     v157 = phi
//     v160 = phi
//     v162 = phi
//     v165 = phi
//     branch v70, #2, #4
// #2: preds: #1
//     v72 = builtin @add v69, v71
//     v75 = builtin @add v74, v73
//     v78 = builtin @add v77, v76
//     v81 = builtin @add v80, v79
//     v83 = builtin @add v82, v68
//     v86 = builtin @add v85, v84
//     v89 = builtin @add v88, v87
//     v92 = builtin @add v91, v90
//     v95 = builtin @add v94, v93
//     v98 = builtin @add v97, v96
//     v101 = builtin @add v100, v99
//     v104 = builtin @add v103, v102
//     v107 = builtin @add v106, v105
//     v110 = builtin @add v109, v108
//     v113 = builtin @add v112, v111
//     v116 = builtin @add v115, v114
//     v119 = builtin @add v118, v117
//     v122 = builtin @add v121, v120
//     v125 = builtin @add v124, v123
//     v128 = builtin @add v127, v126
//     v131 = builtin @add v130, v129
//     v134 = builtin @add v133, v132
//     v137 = builtin @add v136, v135
//     v140 = builtin @add v139, v138
//     v143 = builtin @add v142, v141
//     v146 = builtin @add v145, v144
//     v149 = builtin @add v148, v147
//     v152 = builtin @add v151, v150
//     v155 = builtin @add v154, v153
//     v158 = builtin @add v157, v156
//     v161 = builtin @add v160, v159
//     v163 = builtin @add v162, v5
//     v166 = builtin @add v165, v164
//     v167 = builtin @add v72, v71
//     upsilon v167 -> ^v69
//     upsilon v75 -> ^v74
//     upsilon v78 -> ^v77
//     upsilon v81 -> ^v80
//     upsilon v83 -> ^v82
//     upsilon v86 -> ^v85
//     upsilon v89 -> ^v88
//     upsilon v92 -> ^v91
//     upsilon v95 -> ^v94
//     upsilon v98 -> ^v97
//     upsilon v101 -> ^v100
//     upsilon v104 -> ^v103
//     upsilon v107 -> ^v106
//     upsilon v110 -> ^v109
//     upsilon v113 -> ^v112
//     upsilon v116 -> ^v115
//     upsilon v119 -> ^v118
//     upsilon v122 -> ^v121
//     upsilon v125 -> ^v124
//     upsilon v128 -> ^v127
//     upsilon v131 -> ^v130
//     upsilon v134 -> ^v133
//     upsilon v137 -> ^v136
//     upsilon v140 -> ^v139
//     upsilon v143 -> ^v142
//     upsilon v146 -> ^v145
//     upsilon v149 -> ^v148
//     upsilon v152 -> ^v151
//     upsilon v155 -> ^v154
//     upsilon v158 -> ^v157
//     upsilon v161 -> ^v160
//     upsilon v163 -> ^v162
//     upsilon v166 -> ^v165
//     jump #1
// #4: preds: #1
//     v234 = builtin @add v69, v74
//     builtin @sstore v3, v234
//     v236 = builtin @add v77, v80
//     builtin @sstore v71, v236
//     v238 = builtin @add v82, v85
//     builtin @sstore v73, v238
//     v240 = builtin @add v88, v91
//     builtin @sstore v76, v240
//     v242 = builtin @add v94, v97
//     builtin @sstore v79, v242
//     v244 = builtin @add v100, v103
//     builtin @sstore v68, v244
//     v246 = builtin @add v106, v109
//     builtin @sstore v84, v246
//     v248 = builtin @add v112, v115
//     builtin @sstore v87, v248
//     v250 = builtin @add v118, v121
//     builtin @sstore v90, v250
//     v252 = builtin @add v124, v127
//     builtin @sstore v93, v252
//     v254 = builtin @add v130, v133
//     builtin @sstore v96, v254
//     v256 = builtin @add v136, v139
//     builtin @sstore v99, v256
//     v258 = builtin @add v142, v145
//     builtin @sstore v102, v258
//     v260 = builtin @add v148, v151
//     builtin @sstore v105, v260
//     v262 = builtin @add v154, v157
//     builtin @sstore v108, v262
//     v264 = builtin @add v160, v162
//     builtin @sstore v111, v264
//     v266 = builtin @add v165, v165
//     builtin @sstore v114, v266
//     main_exit
//
// ===== spill info =====
// CFG[0] <main>
//   spilled:
//     v116 (value) -> mem 0x80
//     v118 (phi) -> mem 0xa0
//     v119 (value) -> mem 0xc0
//     v121 (phi) -> mem 0xe0
//     v122 (value) -> mem 0x0100
//     v124 (phi) -> mem 0x0120
//     v125 (value) -> mem 0x0140
//     v127 (phi) -> mem 0x0160
//     v128 (value) -> mem 0x0180
//     v130 (phi) -> mem 0x01a0
//     v131 (value) -> mem 0x01c0
//     v133 (phi) -> mem 0x01e0
//     v134 (value) -> mem 0x0200
//     v136 (phi) -> mem 0x0220
//     v137 (value) -> mem 0x0240
//     v139 (phi) -> mem 0x0260
//     v140 (value) -> mem 0x0280
//     v142 (phi) -> mem 0x02a0
//     v143 (value) -> mem 0x02c0
//     v145 (phi) -> mem 0x02e0
//     v146 (value) -> mem 0x0300
//     v148 (phi) -> mem 0x0320
//     v149 (value) -> mem 0x0340
//     v151 (phi) -> mem 0x0360
//     v152 (value) -> mem 0x0380
//     v154 (phi) -> mem 0x03a0
//     v155 (value) -> mem 0x03c0
//     v157 (phi) -> mem 0x03e0
//     v158 (value) -> mem 0x0400
//     v160 (phi) -> mem 0x0420
//     v161 (value) -> mem 0x0440
//     v162 (phi) -> mem 0x0460
//     v165 (phi) -> mem 0x0480
//   mstore schedule:
//     block entry B#1:
//       mstore addr(v165) <- v165 via [DUP1, STORE phi165]
//       mstore addr(v162) <- v162 via [DUP2, STORE phi162]
//       mstore addr(v160) <- v160 via [DUP3, STORE phi160]
//       mstore addr(v157) <- v157 via [DUP4, STORE phi157]
//       mstore addr(v154) <- v154 via [DUP5, STORE phi154]
//       mstore addr(v151) <- v151 via [DUP6, STORE phi151]
//       mstore addr(v148) <- v148 via [DUP7, STORE phi148]
//       mstore addr(v145) <- v145 via [DUP8, STORE phi145]
//       mstore addr(v142) <- v142 via [DUP9, STORE phi142]
//       mstore addr(v139) <- v139 via [DUP10, STORE phi139]
//       mstore addr(v136) <- v136 via [DUP11, STORE phi136]
//       mstore addr(v133) <- v133 via [DUP12, STORE phi133]
//       mstore addr(v130) <- v130 via [DUP13, STORE phi130]
//       mstore addr(v127) <- v127 via [DUP14, STORE phi127]
//       mstore addr(v124) <- v124 via [DUP15, STORE phi124]
//       mstore addr(v121) <- v121 via [DUP16, STORE phi121]
//       mstore addr(v118) <- v118 via [POP, DUP16, LOAD phi165, SWAP1, STORE phi118]
//     after v116 (B#2):
//       mstore addr(v116) <- v116 via [DUP1, STORE v116]
//     after v119 (B#2):
//       mstore addr(v119) <- v119 via [DUP1, STORE v119]
//     after v122 (B#2):
//       mstore addr(v122) <- v122 via [DUP1, STORE v122]
//     after v125 (B#2):
//       mstore addr(v125) <- v125 via [DUP1, STORE v125]
//     after v128 (B#2):
//       mstore addr(v128) <- v128 via [DUP1, STORE v128]
//     after v131 (B#2):
//       mstore addr(v131) <- v131 via [DUP1, STORE v131]
//     after v134 (B#2):
//       mstore addr(v134) <- v134 via [DUP1, STORE v134]
//     after v137 (B#2):
//       mstore addr(v137) <- v137 via [DUP1, STORE v137]
//     after v140 (B#2):
//       mstore addr(v140) <- v140 via [DUP1, STORE v140]
//     after v143 (B#2):
//       mstore addr(v143) <- v143 via [DUP1, STORE v143]
//     after v146 (B#2):
//       mstore addr(v146) <- v146 via [DUP1, STORE v146]
//     after v149 (B#2):
//       mstore addr(v149) <- v149 via [DUP1, STORE v149]
//     after v152 (B#2):
//       mstore addr(v152) <- v152 via [DUP1, STORE v152]
//     after v155 (B#2):
//       mstore addr(v155) <- v155 via [DUP1, STORE v155]
//     after v158 (B#2):
//       mstore addr(v158) <- v158 via [DUP1, STORE v158]
//     after v161 (B#2):
//       mstore addr(v161) <- v161 via [DUP1, STORE v161]
