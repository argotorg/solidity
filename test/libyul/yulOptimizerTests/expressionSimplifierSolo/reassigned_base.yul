{
    let v := calldataload(0)
    let a := add(v, 2)
    v := calldataload(32)
    // `a` is not `v` plus 2 any more.
    sstore(add(a, 3), 1)
    let b := add(v, 2)
    sstore(add(b, 3), 1)
}
// ----
// step: expressionSimplifierSolo
//
// {
//     let v := calldataload(0)
//     let a := add(v, 2)
//     v := calldataload(32)
//     sstore(add(a, 3), 1)
//     let b := add(v, 2)
//     sstore(add(v, 5), 1)
// }
