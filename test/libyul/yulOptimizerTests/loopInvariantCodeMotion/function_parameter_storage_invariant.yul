{
    function f(slot) {
        for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
            let inv := sload(slot)
            a := add(a, 1)
            mstore(a, inv)
        }
    }
}
// ----
// step: loopInvariantCodeMotion
//
// {
//     function f(slot)
//     {
//         let a := 1
//         let inv := sload(slot)
//         for { } iszero(eq(a, 10)) { a := add(a, 1) }
//         {
//             a := add(a, 1)
//             mstore(a, inv)
//         }
//     }
// }
