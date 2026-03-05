{
    { let a, b, c, d, f }
    {
        function f(a) -> c, d {
            let b, c_1 := f(a)
        }
    }
}
// ----
// step: disambiguator
//
// {
//     { let a, b, c, d, f }
//     {
//         function f_1(a_1) -> c_2, d_1
//         { let b_1, c_1 := f_1(a_1) }
//     }
// }
