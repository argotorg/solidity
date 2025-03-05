contract A layout at true ? 42 : 94 {}
contract B layout at 255 + (true ? 1 : 0) {}
// ----
// TypeError 6396: (21-35): The base slot of the storage layout must evaluate to a rational number.
// TypeError 6396: (60-80): The base slot of the storage layout must evaluate to a rational number.
