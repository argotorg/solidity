// nested object to show that optimizations are applied at all levels
object "A" {
    code
    {
        mstore(43, 33)  // removed by optimizer as it's transient and otherwise unused
    }

    object "B"
    {
        code
        {
            let y := 42
            sstore(y, y)  // persists
            mstore(y, y)  // removed
        }

        object "C"
        {
            code
            {
                let x := 55
                sstore(x, x)  // persists
                mstore(x, x)  // removed
            }
        }
    }
}
// ----
// step: fullSuite
//
// object "A" {
//     code { { } }
//     object "B" {
//         code { { sstore(42, 42) } }
//         object "C" {
//             code { { sstore(55, 55) } }
//         }
//     }
// }
