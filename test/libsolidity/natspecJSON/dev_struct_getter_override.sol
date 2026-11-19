interface IThing {
    struct Value {
        uint128 x;
        uint128 y;
    }

    /// @return v a value
    function value() external view returns (Value memory v);
}

contract Thing is IThing {
    Value public override value;
}

// ----
// ----
// :IThing devdoc
// {
//     "kind": "dev",
//     "methods":
//     {
//         "value()":
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
//             "return": "a value",
//             "returns":
//             {
//                 "_0": "a value"
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
