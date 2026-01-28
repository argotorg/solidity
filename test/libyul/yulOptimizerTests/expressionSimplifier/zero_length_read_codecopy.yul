{
	codecopy(calldataload(4), calldataload(5), sub(42,42))
}
// ====
// bytecodeFormat: legacy
// ----
// step: expressionSimplifier
//
// {
//     {
//         codecopy(0, calldataload(5), 0)
//     }
// }
