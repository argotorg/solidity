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
//         let _4 := _1
//         let _5 := 0
//         sstore(_5, _4)
//         pop(extcall(_5, _5, _5, _5))
//         sstore(_5, _1)
//     }
// }
