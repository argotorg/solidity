interface IThing {
    struct Value {
        uint128 x;
        uint128 y;
    }

    /// @param v value to search for
    /// @return the value
    function value(uint256 v) external view returns (Value memory);
}

contract Thing is IThing {
    mapping(uint256 => Value) public override value;
}
// ----
// ----
// :IThing devdoc
// {
//     "kind": "dev",
//     "methods":
//     {
//         "value(uint256)":
//         {
//             "params":
//             {
//                 "v": "value to search for"
//             },
//             "returns":
//             {
//                 "_0": "the value"
//             }
//         }
//     },
//     "version": 1
// }
//
// :IThing userdoc
// {
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
//
// :Thing devdoc
// {
//     "kind": "dev",
//     "methods": {},
//     "stateVariables":
//     {
//         "value":
//         {
//             "params":
//             {
//                 "v": "value to search for"
//             },
//             "return": "the value",
//             "returns":
//             {
//                 "_0": "the value"
//             }
//         }
//     },
//     "version": 1
// }
//
// :Thing userdoc
// {
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
