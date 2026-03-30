{
	// x_1 is a function name, so the suffix counter must skip it
	// when cleaning x_100 and x_200 which both strip to "x"
	function x_1() {}
	let x := 1
	let x_100 := 2
	let x_200 := 3
}
// ----
// step: varNameCleaner
//
// {
//     {
//         let x := 1
//         let x_2 := 2
//         let x_3 := 3
//     }
//     function x_1()
//     { }
// }
