// We cannot substitute `a` in `let b := a`
{
	let a := extcodesize(0)
	a := mul(a, 2)
	let b := a
}
// ====
// bytecodeFormat: legacy
// ----
// step: rematerialiser
//
// {
//     let a := extcodesize(0)
//     a := mul(a, 2)
//     let b := a
// }
