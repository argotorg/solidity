pragma abicoder v2;

contract C {
    struct S {
        bytes b;
        uint16[] a;
        uint16 u;
    }

    S s;
    constructor() {
        uint16[] memory a = new uint16[](2);
        a[0] = 13;
        a[1] = 14;

        s.b = "foo";
        s.a = a;
        s.u = 21;
    }

    mapping (uint => S) m;

    function from_state() public returns (S memory) {
        m[0] = s;
        return m[0];
    }

    function from_storage() public returns (S memory) {
        S storage sLocal = s;
        m[1] = sLocal;
        return m[1];
    }

    function from_memory() public returns (S memory) {
        S memory sMemory = s;
        m[2] = sMemory;
        return m[2];
    }


    function from_calldata(S calldata sCalldata) public returns (S memory) {
        m[3] = sCalldata;
        return m[3];
    }
}
// ----
// from_state() -> 0x20, 0x60, 0xa0, 21, 3, 0x666F6F0000000000000000000000000000000000000000000000000000000000, 2, 13, 14
// gas irOptimized: 121560
// gas legacy: 125554
// gas legacyOptimized: 121763
// gas ssaCFGOptimized: 121493
// from_storage() -> 0x20, 0x60, 0xa0, 21, 3, 0x666F6F0000000000000000000000000000000000000000000000000000000000, 2, 13, 14
// gas irOptimized: 121604
// gas legacy: 125612
// gas legacyOptimized: 121815
// gas ssaCFGOptimized: 121537
// from_memory() -> 0x20, 0x60, 0xa0, 21, 3, 0x666F6F0000000000000000000000000000000000000000000000000000000000, 2, 13, 14
// gas irOptimized: 122809
// gas legacy: 125423
// gas legacyOptimized: 123339
// gas ssaCFGOptimized: 122706
// from_calldata((bytes,uint16[],uint16)): 0x20, 0x60, 0xa0, 21, 3, 0x666F6F0000000000000000000000000000000000000000000000000000000000, 2, 13, 14 -> 0x20, 0x60, 0xa0, 21, 3, 0x666f6f0000000000000000000000000000000000000000000000000000000000, 2, 13, 14
// gas irOptimized: 114877
// gas legacy: 118207
// gas legacyOptimized: 115359
// gas ssaCFGOptimized: 114801
