contract A {
    uint256 data;

    constructor() m {
        data |= 2;
    }

    modifier m {
        data |= 1;
        _;
    }

    function getData() public returns (uint256 r) {
        return data;
    }
}


contract C is A {
    constructor() {
        data |= 4;
    }
}
// ----
// getData() -> 7
