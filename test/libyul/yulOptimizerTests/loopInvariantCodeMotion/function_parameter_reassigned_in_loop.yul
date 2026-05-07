{
    function f(x) {
        for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
            let not_inv := add(x, 42)
            x := add(x, 1)
            mstore(a, not_inv)
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
//         for { } iszero(eq(a, 10)) { a := add(a, 1) }
//         {
//             let not_inv := add(x, 42)
//             x := add(x, 1)
//             mstore(a, not_inv)
//         }
//     }
// }
