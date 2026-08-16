contract Base {
    uint internal immutable value = 1;

    function read() public pure returns (uint) {
        return value;
    }
}

contract Derived is Base {
    constructor() {
        value = block.number;
    }
}
// ----
// TypeError 2527: (120-125): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
