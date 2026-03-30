{
	function f()
	{
		let x_10 := 1
		let x_20 := 2
		let x_30 := 3
	}
	function g()
	{
		let x_40 := 4
		let x_50 := 5
		let x_60 := 6
	}
}
// ----
// step: varNameCleaner
//
// {
//     { }
//     function f()
//     {
//         let x := 1
//         let x_1 := 2
//         let x_2 := 3
//     }
//     function g()
//     {
//         let x := 4
//         let x_1 := 5
//         let x_2 := 6
//     }
// }
