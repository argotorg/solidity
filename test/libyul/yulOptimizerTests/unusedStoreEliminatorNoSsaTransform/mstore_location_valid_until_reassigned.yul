// Reassignments after the stores do not prevent the elimination: the first mstore is
// overwritten before x changes.
{
    let x := calldataload(0)
    let y := add(x, 32)
    mstore(y, 1)
    mstore(y, 2)
    x := calldataload(32)
    return(y, 32)
}
// ----
// step: unusedStoreEliminatorNoSsaTransform
//
// {
//     let x := calldataload(0)
//     let y := add(x, 32)
//     mstore(y, 2)
//     x := calldataload(32)
//     return(y, 32)
// }
