contract A {
    uint constant x = 10;
}

contract C is A layout at A.x { }
// ----
// TypeError 6396: (68-71): The base slot of the storage layout must evaluate to a rational number.
