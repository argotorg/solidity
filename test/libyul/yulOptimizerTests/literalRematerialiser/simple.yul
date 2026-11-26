{
    let x := 7
    let y := x
    let z := calldataload(0)
    sstore(y, z)
}
// ----
// step: literalRematerialiser
//
// {
//     let x := 7
//     let y := 7
//     let z := calldataload(0)
//     sstore(7, z)
// }
