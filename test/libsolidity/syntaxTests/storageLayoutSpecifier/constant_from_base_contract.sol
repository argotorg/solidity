contract A {
    uint constant x = 10;
}

contract C is A layout at A.x { }
// ----
// TypeError 1505: (68-71): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
