{
    let x := calldataload(0)
    x := calldataload(32) // Reassignment; x gets a new version, which a and b both refer to
    let a := add(x, 32)
    let b := x
    let outLen := 32
    mstore(a, 0xAA) // Unused, no overlap with [b, b+outLen]
    return(b, outLen)
}
// ----
// step: unusedStoreEliminatorNoSsaTransform
//
// {
//     let x := calldataload(0)
//     x := calldataload(32)
//     let a := add(x, 32)
//     let b := x
//     let outLen := 32
//     return(b, outLen)
// }
