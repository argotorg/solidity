{
    let a := gas()
    let b := gas()
}
// ====
// bytecodeFormat: legacy
// ----
// step: commonSubexpressionEliminator
//
// {
//     let a := gas()
//     let b := gas()
// }
