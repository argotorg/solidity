{
	revert(call(0,0,0,0,0,0,0), 0)
}
// ====
// bytecodeFormat: legacy
// ----
// step: expressionSimplifier
//
// {
//     {
//         let _1 := 0
//         pop(call(_1, _1, _1, _1, _1, _1, _1))
//         revert(0, _1)
//     }
// }
