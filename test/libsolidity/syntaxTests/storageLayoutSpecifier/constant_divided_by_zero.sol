uint constant N = 100;
contract C layout at N / 0 {}
// ----
// TypeError 6396: (44-49): The base slot of the storage layout must evaluate to a rational number.
