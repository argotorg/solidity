{
    let x := calldataload(0)
    let y := add(x, 32) // Transitively depends on x
    let b := x
    x := calldataload(32) // Reassignment; y and b keep referring to the old version of x
    let a := y
    let outLen := 32
    mstore(a, 0xAA) // Unused, no overlap with [b, b+outLen]
    return(b, outLen)
}
// ----
// step: unusedStoreEliminatorNoSsaTransform
//
// {
//     let x := calldataload(0)
//     let y := add(x, 32)
//     let b := x
//     x := calldataload(32)
//     let a := y
//     let outLen := 32
//     return(b, outLen)
// }
