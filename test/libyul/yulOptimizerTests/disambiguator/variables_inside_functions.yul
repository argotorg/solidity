{
    { let c let b }
    function f(a, c) -> b { let x }
    {
        let a let x
    }
}
// ----
// step: disambiguator
//
// {
//     {
//         let c
//         let b
//     }
//     function f(a, c_1) -> b_1
//     { let x }
//     {
//         let a_1
//         let x_1
//     }
// }
