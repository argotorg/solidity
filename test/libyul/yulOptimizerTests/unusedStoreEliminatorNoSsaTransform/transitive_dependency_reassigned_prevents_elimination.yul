{
    let x := calldataload(0)
    let y := add(x, 32)
    x := calldataload(32)
    let a := y
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
//     let y := add(x, 32)
//     x := calldataload(32)
//     let a := y
//     let b := x
//     let outLen := 32
//     mstore(a, 0xAA)
//     return(b, outLen)
// }
