contract B {
    uint immutable x = 3;

    function readX() internal virtual returns(uint) {
        return x;
    }
}

contract C is B {
    constructor() {
        B.readX;
    }

    function readX() internal pure override returns(uint) {
        return 3;
    }
}
// ----
// Warning 6133: (167-174): Statement has no effect.
