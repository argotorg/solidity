contract A layout at [1, 2, 3][0] {}
contract B layout at 255 + [1, 2, 3][0] {}
// ----
// TypeError 6396: (21-33): The base slot of the storage layout must evaluate to a rational number.
// TypeError 6396: (58-76): The base slot of the storage layout must evaluate to a rational number.
