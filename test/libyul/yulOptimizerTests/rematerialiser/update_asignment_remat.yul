// We cannot substitute `a` in `let b := a`
{
	let a := balance(0)
	a := mul(a, 2)
	let b := a
}
// ----
// step: rematerialiser
//
// {
//     let a := balance(0)
//     a := mul(a, 2)
//     let b := a
// }
