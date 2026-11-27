// mstore(p, ...) must NOT be eliminated: `p` is declared in the loop body and never reassigned,
// but has a different value in each iteration. The next iteration reads the stored word through
// sub(p, 32).
{
    sstore(0, 0x100)
    let s := 0
    for { let i := 0 } lt(i, 3) { i := add(i, 1) } {
        let p := sload(0)
        s := add(s, mload(sub(p, 32)))
        mstore(p, add(i, 7))
        sstore(0, add(p, 32))
    }
    sstore(1, s)
    stop()
}
// ----
// step: unusedStoreEliminator
//
// {
//     {
//         sstore(0, 0x100)
//         let s := 0
//         let s_14 := s
//         let i := 0
//         let i_15 := i
//         for { }
//         lt(i, 3)
//         {
//             let s_20 := s
//             let i_21 := i
//             i := add(i_21, 1)
//             let i_16 := i
//         }
//         {
//             let s_18 := s
//             let i_19 := i
//             let p := sload(0)
//             s := add(s_18, mload(sub(p, 32)))
//             let s_17 := s
//             mstore(p, add(i_19, 7))
//             sstore(0, add(p, 32))
//         }
//         let s_22 := s
//         let i_23 := i
//         sstore(1, s_22)
//         stop()
//     }
// }
