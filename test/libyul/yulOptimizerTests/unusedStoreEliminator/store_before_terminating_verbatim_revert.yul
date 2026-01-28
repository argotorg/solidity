{
    let x := 0
    let y := 1
    sstore(x, y)
    // opcodes: PUSH1 0x00 DUP1 RETURN
    // SSTORE is not redundant due to the RETURN hidden in the verbatim block. It must not be removed.
    verbatim_0i_0o(hex"600080F3")
    revert(0,0)
}
// ----
// step: unusedStoreEliminator
//
// {
//     {
//         let x := 0
//         sstore(x, 1)
//         verbatim_0i_0o("`\x00\x80\xf3")
//         revert(0, 0)
//     }
// }
