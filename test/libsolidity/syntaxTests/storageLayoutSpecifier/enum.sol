enum Color {Red, Green, Blue}

contract C layout at Color.Red {}
// ----
// TypeError 1763: (52-61): The base slot of the storage layout must evaluate to an integer.
