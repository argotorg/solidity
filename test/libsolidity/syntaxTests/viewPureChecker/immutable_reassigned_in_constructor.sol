contract C {
    uint immutable x = 1;

    constructor() {
        x = block.number;
    }

    function f() public pure returns (uint) {
        return x;
    }
}

contract D {
    uint immutable y = 1;

    constructor() {
        D.y = 2;
    }

    function f() public pure returns (uint) {
        return D.y;
    }
}
// ----
// TypeError 2527: (154-155): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (311-314): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
