{
    let x := 0x0101
    let y := 0x0202
    let z := 0x0303
    switch sload(x)
    case 0 {
        x := 0x42
    }
    case 1 {
        y := 0x42
    }
    default {
        sstore(z, z)
    }

    sstore(0x0404, y)
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x0101
//     v1 = const 0x0202
//     v2 = const 0x0303
//     ; [lit0]
//     v3 = builtin @sload v0
//     v4 = const 0x00
//     ; [v3, lit4, v3]
//     v5 = builtin @eq v3, v4
//     v6 = const 0x42
//     v7 = const 0x01
//     v14 = const 0x0404
//     ; out: [v3, v5]
//     branch v5, #2, #3
// #1: preds: #2, #4, #5
//     ; in: [phi10]
//     v10 = phi
//     ; [phi10, lit14]
//     builtin @sstore v14, v10
//     ; out: []
//     main_exit
// #2: preds: #0
//     ; in: [JUNK]
//     upsilon v1 -> ^v10
//     ; out: [JUNK]
//     jump #1
// #3: preds: #0
//     ; in: [v3]
//     ; [lit7, v3]
//     v8 = builtin @eq v3, v7
//     ; out: [v8]
//     branch v8, #4, #5
// #4: preds: #3
//     ; in: []
//     upsilon v6 -> ^v10
//     ; out: []
//     jump #1
// #5: preds: #3
//     ; in: []
//     ; [lit2, lit2]
//     builtin @sstore v2, v2
//     upsilon v1 -> ^v10
//     ; out: []
//     jump #1
//
