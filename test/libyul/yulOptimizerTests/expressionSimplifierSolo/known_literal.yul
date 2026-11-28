{
    let x := 7
    let y := calldataload(0)
    sstore(add(x, 3), mul(y, 1))
}
// ----
// step: expressionSimplifierSolo
//
// {
//     let x := 7
//     let y := calldataload(0)
//     sstore(10, y)
// }
