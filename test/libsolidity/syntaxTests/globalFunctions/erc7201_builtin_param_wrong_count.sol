contract C {
    uint x = erc7201();
    uint y = erc7201("12", "34");
    uint z = erc7201("A", "BC", "D");
}
// ----
// TypeError 6160: (26-35): Wrong argument count for function call: 0 arguments given but expected 1.
// TypeError 6160: (50-69): Wrong argument count for function call: 2 arguments given but expected 1.
// TypeError 6160: (84-107): Wrong argument count for function call: 3 arguments given but expected 1.
