interface IThing {
    struct Value {
        uint128 x;
        uint128 y;
    }

    /// @return v a value
    function value(uint) external view returns (Value memory v);
}

contract Thing is IThing {
    mapping(uint => Value w) public override value;
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
//             "returns":
//             {
//                 "v": "a value"
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
//             "return": "w a value",
//             "returns":
//             {
//                 "w": "a value"
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
