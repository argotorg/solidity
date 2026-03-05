{
  let b := true
  let c := false
  c := b
  b := false

  let a := 1
  a := add(a, 1)
  if c {
    a := add(a, 1)
  }
  a := add(a, 1)
  mstore(a, 1)
}
// ----
// step: ssaTransform
//
// {
//     let b_1 := true
//     let b := b_1
//     let c_1 := false
//     let c := c_1
//     let c_2 := b_1
//     c := c_2
//     let b_2 := false
//     b := b_2
//     let a_1 := 1
//     let a := a_1
//     let a_2 := add(a_1, 1)
//     a := a_2
//     if c_2
//     {
//         let a_3 := add(a_2, 1)
//         a := a_3
//     }
//     let a_5 := a
//     let a_4 := add(a_5, 1)
//     a := a_4
//     mstore(a_4, 1)
// }
