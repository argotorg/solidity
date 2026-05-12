{
  let x := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
  let y := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
}
// ====
// EVMVersion: >=constantinople
// ----
// step: constantOptimiserWithMemoryMasks
//
// {
//     let x := not(0)
//     let y := mload(127)
// }
