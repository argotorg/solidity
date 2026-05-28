{
	let x_5 := 42
	let y_3 := x_5
	let z_1 := add(x_5, y_3)
}
// ----
// step: varNameCleaner
//
// {
//     {
//         let x := 42
//         let y := x
//         let z := add(x, y)
//     }
// }
