contract C {
    int[erc7201(123)] a;
}
// ----
// TypeError 9796: (29-32): Invalid argument type for erc7201 function. Expected literal or constant string.
// TypeError 5462: (21-33): Invalid array length, expected integer literal or constant expression.
