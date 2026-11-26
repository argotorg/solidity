interface IThing {
    struct Value {
        uint128 x;
        uint128 A;
    }

    ///@return
    function value(uint) external returns (Value memory);
}

contract Thing is IThing {
    mapping(uint=>Value x) public override value;
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
//                 "_0": ""
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
//             "return": "x ",
//             "returns":
//             {
//                 "x": ""
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
