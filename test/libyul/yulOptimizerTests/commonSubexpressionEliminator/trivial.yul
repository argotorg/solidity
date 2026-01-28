{
    let a := mul(1, calldataload(0))
    let b := mul(1, calldataload(0))
}
// ----
// step: commonSubexpressionEliminator
//
// {
//     let a := mul(1, calldataload(0))
//     let b := a
// }
