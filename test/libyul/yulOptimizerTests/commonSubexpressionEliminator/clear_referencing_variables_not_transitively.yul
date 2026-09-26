{
    let a := calldataload(0)
    let b := add(a, 1)
    let c := add(b, 2)
    a := calldataload(32)
    sstore(0, add(b, 2))
}
// ----
// step: commonSubexpressionEliminator
//
// {
//     let a := calldataload(0)
//     let b := add(a, 1)
//     let c := add(b, 2)
//     a := calldataload(32)
//     sstore(0, c)
// }
