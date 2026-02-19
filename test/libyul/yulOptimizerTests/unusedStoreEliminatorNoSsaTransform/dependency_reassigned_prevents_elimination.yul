{
    let x := calldataload(0)
    x := calldataload(32)
    let a := add(x, 32)
    let b := x
    let outLen := 32
    mstore(a, 0xAA)
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
//     mstore(a, 0xAA)
//     return(b, outLen)
// }
