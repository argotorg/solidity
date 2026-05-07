{
    function f(x) {
        for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
            let inv := add(x, 42)
            a := add(a, 1)
            mstore(a, inv)
        }
    }
}
// ----
// step: loopInvariantCodeMotion
//
// {
//     function f(x)
//     {
//         let a := 1
//         let inv := add(x, 42)
//         for { } iszero(eq(a, 10)) { a := add(a, 1) }
//         {
//             a := add(a, 1)
//             mstore(a, inv)
//         }
//     }
// }
