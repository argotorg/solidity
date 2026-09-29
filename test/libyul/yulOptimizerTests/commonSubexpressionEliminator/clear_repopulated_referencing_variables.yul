{
    let a := calldataload(0)
    let b := add(a, 1)
    a := calldataload(32)
    b := add(a, 1)
    a := calldataload(64)
    sstore(0, add(a, 1))
}
// ----
// step: commonSubexpressionEliminator
//
// {
//     let a := calldataload(0)
//     let b := add(a, 1)
//     a := calldataload(32)
//     b := add(a, 1)
//     a := calldataload(64)
//     sstore(0, add(a, 1))
// }
