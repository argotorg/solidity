contract C {
    uint[erc7201("main:example") + erc7201("main:example")] array;
}
// ----
// TypeError 2643: (22-71): Arithmetic error when computing constant value.
