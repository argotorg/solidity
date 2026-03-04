pragma abicoder v2;

contract C {
    uint8[][] a;
    uint8[][][] a2;

    function test(uint8[][][] calldata _a) public {
        a = _a[1];
        require(a.length == 2);
        require(a[0].length == 1);
        require(a[0][0] == 7);
        require(a[1].length == 2);
        require(a[1][0] == 8);
        require(a[1][1] == 9);
    }

    function test2(uint8[][] calldata _a) public {
        a2 = new uint8[][][](2);
        a2[0] = _a;
        require(a2[0].length == 2);
	require(a2[0][0].length == 1);
	require(a2[0][0][0] == 7);
	require(a2[0][1].length == 2);
	require(a2[0][1][0] == 8);
	require(a2[0][1][1] == 9);
	require(a2[1].length == 0);
    }
}
// ----
// test(uint8[][][]): 0x20, 2, 0x40, 0x60, 0, 2, 0x40, 0x80, 1, 7, 2, 8, 9
// gas irOptimized: 137891
// gas legacy: 140273
// gas legacyOptimized: 138487
// test2(uint8[][]): 0x20, 2, 0x40, 0x80, 1, 7, 2, 8, 9
// gas irOptimized: 164249
// gas legacy: 167430
// gas legacyOptimized: 164772
