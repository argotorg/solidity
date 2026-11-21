{
    let x := calldataload(0)
    sstore(x, 1)
    x := 7
    sstore(x, 2)
    x := calldataload(32)
    sstore(x, 3)
}
// ----
// step: literalRematerialiserSolo
//
// {
//     let x := calldataload(0)
//     sstore(x, 1)
//     x := 7
//     sstore(7, 2)
//     x := calldataload(32)
//     sstore(x, 3)
// }
