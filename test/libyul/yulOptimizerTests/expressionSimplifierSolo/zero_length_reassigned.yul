{
    let p := calldataload(0)
    let len := calldataload(64)
    if calldataload(32) {
        len := 0
        log0(p, len)
    }
    // `len` may not be zero any more.
    log0(p, len)
}
// ----
// step: expressionSimplifierSolo
//
// {
//     let p := calldataload(0)
//     let len := calldataload(64)
//     if calldataload(32)
//     {
//         len := 0
//         log0(0, len)
//     }
//     log0(p, len)
// }
