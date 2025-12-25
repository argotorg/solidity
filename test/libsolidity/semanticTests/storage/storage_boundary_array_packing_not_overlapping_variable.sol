contract C {
    struct Canary {
        uint256 value;
    }

    constructor() {
        Canary storage canary = getCanary();
        canary.value = type(uint256).max; // Should not be overwritten
    }

    function getArray() internal pure returns (uint64[10][1] storage _x) {
        // Array of 10 * uint64 values (8 bytes each)
        // Packs 4 uint64 per slot -> 3 slots total (slots -1, 0, 1)
        assembly {
            _x.slot := sub(0, 1)
        }
    }

    function getCanary() internal pure returns (Canary storage canary) {
        // Canary at slot 2, right after the array ends at slot 1
        assembly {
            canary.slot := 2
        }
    }

    function fillArray() public {
        uint64[10][1] storage _x = getArray();
        for (uint64 i = 0; i < 10; i++)
            _x[0][i] = i;
    }

    function shrinkTo5() public {
        uint64[10][1] storage _x = getArray();
        // Resize by assigning a smaller array
        // This should clear items [5..9] without touching y
        _x[0] = [uint64(11), 12, 13, 14, 15];
    }

    function clearArray() public {
        uint64[10][1] storage _x = getArray();
        delete _x[0];
    }

    function x() public view returns (uint64[10] memory) {
        return getArray()[0];
    }

    function canaryValue() public view returns (uint256) {
        return getCanary().value;
    }
}
// ----
// x() -> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// fillArray()
// x() -> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// shrinkTo5()
// x() -> 11, 12, 13, 14, 15, 0, 0, 0, 0, 0
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// clearArray()
// x() -> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
