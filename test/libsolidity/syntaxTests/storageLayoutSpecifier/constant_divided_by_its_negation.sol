uint constant N = 100;
contract C layout at N / ~N {}
// ----
// TypeError 6396: (44-50): The base slot of the storage layout must evaluate to a rational number.
