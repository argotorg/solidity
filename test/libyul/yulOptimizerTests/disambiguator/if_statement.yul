{
    { let a, b, c }
    {
        let a
        if a { let b := a }
    }
}
// ----
// step: disambiguator
//
// {
//     { let a, b, c }
//     {
//         let a_1
//         if a_1 { let b_1 := a_1 }
//     }
// }
