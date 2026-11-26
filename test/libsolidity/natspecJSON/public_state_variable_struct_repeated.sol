contract Bank {
    struct Coin {
        string obverseGraphicURL;
        string reverseGraphicURL;
    }

    /// @notice Get the n-th coin I own
    /// @return obverseGraphicURL Front pic
    /// @return obverseGraphicURL Front pic
    Coin[] public coinStack;
}

// ----
// DocstringParsingError 2604: (113-236): Documentation tag "@return obverseGraphicURL Front pic" exceeds the number of return parameters.
