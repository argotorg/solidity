{
	revert(calldataload(0), 0)
	calldatacopy(calldataload(1), calldataload(2), 0)
	return(calldataload(3), 0)
}
// ----
// step: expressionSimplifier
//
// {
//     {
//         let _1 := 0
//         revert(0, _1)
//         calldatacopy(0, calldataload(2), _1)
//         return(0, _1)
//     }
// }
