contract Bank {
    struct Coin {
        string observeGraphicURL;
        string reverseGraphicURL;
    }

    /// @notice Get the n-th coin I own
    /// @return Front and back pic of the coin
    Coin[] public coinStack;
}

// ----
// ----
// :Bank devdoc
// {
//     "kind": "dev",
//     "methods": {},
//     "stateVariables":
//     {
//         "coinStack":
//         {
//             "return": "Front and back pic of the coin",
//             "returns":
//             {
//                 "_0": "Front and back pic of the coin"
//             }
//         }
//     },
//     "version": 1
// }
//
// :Bank userdoc
// {
//     "kind": "user",
//     "methods":
//     {
//         "coinStack(uint256)":
//         {
//             "notice": "Get the n-th coin I own"
//         }
//     },
//     "version": 1
// }
