{
	let x_1 := 1
	function f()
	{
		let x_10 := 1
		let x_20 := 2
		let x_30 := 3
		let x_40 := 4
		let x_50 := 5
	}
	let x_2 := 2
}
// ----
// step: varNameCleaner
//
// {
//     {
//         let x := 1
//         let x_1 := 2
//     }
//     function f()
//     {
//         let x := 1
//         let x_1 := 2
//         let x_2 := 3
//         let x_3 := 4
//         let x_4 := 5
//     }
// }
