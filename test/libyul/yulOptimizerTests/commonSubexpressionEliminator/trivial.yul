{
    let a := mul(1, codesize())
    let b := mul(1, codesize())
}
// ====
// bytecodeFormat: legacy
// ----
// step: commonSubexpressionEliminator
//
// {
//     let a := mul(1, codesize())
//     let b := a
// }
