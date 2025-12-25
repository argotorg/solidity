bool constant x = false;
contract C layout at x {}
// ----
// TypeError 1763: (46-47): The base slot of the storage layout must evaluate to an integer.
