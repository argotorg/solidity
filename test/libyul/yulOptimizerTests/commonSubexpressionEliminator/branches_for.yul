{
	let a := 1
	let b := calldataload(0)
	for { } lt(1, calldataload(0)) { mstore(1, calldataload(0)) a := add(a, calldataload(0)) } {
		mstore(1, calldataload(0))
	}
	mstore(1, calldataload(0))
}
// ----
// step: commonSubexpressionEliminator
//
// {
//     let a := 1
//     let b := calldataload(0)
//     for { }
//     lt(1, b)
//     {
//         mstore(1, b)
//         a := add(a, b)
//     }
//     { mstore(1, b) }
//     mstore(1, b)
// }
