{
    mstore(2, 9)
    sstore(0, mload(2))
    pop(extcall(0, 0, 0, 0))
    sstore(0, mload(2))
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// step: loadResolver
//
// {
//     {
//         let _1 := 9
//         mstore(2, _1)
//         let _2 := _1
//         let _3 := 0
//         sstore(_3, _2)
//         pop(extcall(_3, _3, _3, _3))
//         sstore(_3, _1)
//     }
// }
