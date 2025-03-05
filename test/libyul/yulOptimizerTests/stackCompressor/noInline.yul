{
  let x := 8
  function f() { let y := 9 }
}
// ====
// bytecodeFormat: legacy
// ----
// step: stackCompressor
//
// {
//     { let x := 8 }
//     function f()
//     { let y := 9 }
// }
