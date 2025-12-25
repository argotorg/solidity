==== Source: A.sol ====
/// @notice This event is emitted when a transfer from A occurs.
/// @param from The source account.
/// @param to The destination account.
/// @param amount The amount.
/// @dev A test case!
event TransferA(address indexed from, address indexed to, uint amount);

contract AContract {
    /// @notice This event is emitted when a transfer from AContract occurs.
    /// @param from The source account.
    /// @param to The destination account.
    /// @param amount The amount.
    /// @dev A test case!
    event TransferAContract(address indexed from, address indexed to, uint amount);
}

==== Source: ERC20.sol ====
import * as A from "A.sol";
contract ERC20 {
    /// @notice This event is emitted when a transfer from ERC20 occurs.
    /// @param from The source account.
    /// @param to The destination account.
    /// @param amount The amount.
    /// @dev A test case!
    event Transfer(address indexed from, address indexed to, uint amount);

    function test() public {
        emit Transfer(address(1), address(5), 1);
        emit A.AContract.TransferAContract(address(1), address(5), 1);
        emit A.TransferA(address(1), address(5), 1);
    }
}

// ----
// ----
// A.sol:AContract devdoc
// {
//     "events": {
//         "TransferAContract(address,address,uint256)": {
//             "details": "A test case!",
//             "params": {
//                 "amount": "The amount.",
//                 "from": "The source account.",
//                 "to": "The destination account."
//             }
//         }
//     },
//     "kind": "dev",
//     "methods": {},
//     "version": 1
// }
//
// A.sol:AContract userdoc
// {
//     "events": {
//         "TransferAContract(address,address,uint256)": {
//             "notice": "This event is emitted when a transfer from AContract occurs."
//         }
//     },
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
//
// ERC20.sol:ERC20 devdoc
// {
//     "events": {
//         "Transfer(address,address,uint256)": {
//             "details": "A test case!",
//             "params": {
//                 "amount": "The amount.",
//                 "from": "The source account.",
//                 "to": "The destination account."
//             }
//         },
//         "TransferA(address,address,uint256)": {
//             "details": "A test case!",
//             "params": {
//                 "amount": "The amount.",
//                 "from": "The source account.",
//                 "to": "The destination account."
//             }
//         },
//         "TransferAContract(address,address,uint256)": {
//             "details": "A test case!",
//             "params": {
//                 "amount": "The amount.",
//                 "from": "The source account.",
//                 "to": "The destination account."
//             }
//         }
//     },
//     "kind": "dev",
//     "methods": {},
//     "version": 1
// }
//
// ERC20.sol:ERC20 userdoc
// {
//     "events": {
//         "Transfer(address,address,uint256)": {
//             "notice": "This event is emitted when a transfer from ERC20 occurs."
//         },
//         "TransferA(address,address,uint256)": {
//             "notice": "This event is emitted when a transfer from A occurs."
//         },
//         "TransferAContract(address,address,uint256)": {
//             "notice": "This event is emitted when a transfer from AContract occurs."
//         }
//     },
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
