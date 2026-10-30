contract A {
    modifier m { _; }
}

contract B is A {}
contract C is A,B {}
