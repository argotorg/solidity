==== Source: A.sol ====
/// Something failed.
/// @dev an error.
/// @param a first parameter
/// @param b second parameter
error E(uint a, uint b);

contract AContract {
    /// Something failed.
    /// @dev an error.
    /// @param a first parameter
    /// @param b second parameter
    error EAContract(uint a, uint b);
}

==== Source: ERC20.sol ====
import * as A from "A.sol";
contract ERC20 {
    /// Something failed.
    /// @dev an error.
    /// @param a first parameter
    /// @param b second parameter
    error EERC20(uint a, uint b);

    function f(uint a) public pure {
        if (a > 0)
            revert EERC20(1, 2);
        else if (a < 0)
            revert A.AContract.EAContract(5, 6);
        else
            revert A.E(5, 6);
    }
}

// ----
// ----
// A.sol:AContract devdoc
// {
//     "errors": {
//         "EAContract(uint256,uint256)": [
//             {
//                 "details": "an error.",
//                 "params": {
//                     "a": "first parameter",
//                     "b": "second parameter"
//                 }
//             }
//         ]
//     },
//     "kind": "dev",
//     "methods": {},
//     "version": 1
// }
//
// A.sol:AContract userdoc
// {
//     "errors": {
//         "EAContract(uint256,uint256)": [
//             {
//                 "notice": "Something failed."
//             }
//         ]
//     },
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
//
// ERC20.sol:ERC20 devdoc
// {
//     "errors": {
//         "E(uint256,uint256)": [
//             {
//                 "details": "an error.",
//                 "params": {
//                     "a": "first parameter",
//                     "b": "second parameter"
//                 }
//             }
//         ],
//         "EAContract(uint256,uint256)": [
//             {
//                 "details": "an error.",
//                 "params": {
//                     "a": "first parameter",
//                     "b": "second parameter"
//                 }
//             }
//         ],
//         "EERC20(uint256,uint256)": [
//             {
//                 "details": "an error.",
//                 "params": {
//                     "a": "first parameter",
//                     "b": "second parameter"
//                 }
//             }
//         ]
//     },
//     "kind": "dev",
//     "methods": {},
//     "version": 1
// }
//
// ERC20.sol:ERC20 userdoc
// {
//     "errors": {
//         "E(uint256,uint256)": [
//             {
//                 "notice": "Something failed."
//             }
//         ],
//         "EAContract(uint256,uint256)": [
//             {
//                 "notice": "Something failed."
//             }
//         ],
//         "EERC20(uint256,uint256)": [
//             {
//                 "notice": "Something failed."
//             }
//         ]
//     },
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
