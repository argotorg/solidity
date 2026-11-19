contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }
    // Same element layout as Node (2 slots), but non-recursive, so its copy never gets the
    // overlap guard and always takes the direct storage-to-storage path with no snapshot.
    struct FlatChild {
        uint256 pad;
        uint256 balance;
    }
    struct FlatNode {
        FlatChild[] children;
        uint256 balance;
    }

    Node recSource;
    Node recTarget;
    FlatNode flatSource;
    FlatNode flatTarget;

    function setUp() external {
        for (uint256 i = 0; i < 8; i++) {
            recSource.children.push();
            recSource.children[i].balance = i + 1;
            flatSource.children.push();
            flatSource.children[i].balance = i + 1;
        }
        recSource.balance = 777;
        flatSource.balance = 777;
    }

    function allocated() internal pure returns (uint256 memPtr) {
        assembly { memPtr := mload(0x40) }
    }

    // Disjoint roots. At runtime the overlap guard walks the target for the source, finds them
    // disjoint, and copies directly without allocating a memory snapshot.
    function copyRecursive() external returns (uint256 memoryGrowth, uint256 check) {
        uint256 before = allocated();
        recTarget = recSource;
        memoryGrowth = allocated() - before;
        check = recTarget.children[7].balance;
    }

    // Non-recursive: no guard, direct path, no memory allocation.
    function copyFlat() external returns (uint256 memoryGrowth, uint256 check) {
        uint256 before = allocated();
        flatTarget = flatSource;
        memoryGrowth = allocated() - before;
        check = flatTarget.children[7].balance;
    }

    // Each disjoint copy skips the snapshot, in any number of copies per transaction.
    function copyRecursiveTwice() external returns (uint256 firstGrowth, uint256 secondGrowth) {
        uint256 m0 = allocated();
        recTarget = recSource;
        uint256 m1 = allocated();
        recTarget = recSource;
        secondGrowth = allocated() - m1;
        firstGrowth = m1 - m0;
    }

    // The source is reached through a storage pointer. The overlap check is a runtime walk, so it
    // still finds the operands disjoint and skips the snapshot, exactly like the plain copy above.
    function copyViaPointer() external returns (uint256 memoryGrowth, uint256 check) {
        Node storage source = recSource;
        uint256 before = allocated();
        recTarget = source;
        memoryGrowth = allocated() - before;
        check = recTarget.children[7].balance;
    }

    // The target contains the source, so the runtime walk finds the overlap and snapshots the
    // source subtree to memory before copying. The buffer is released after the copy, so even
    // this case shows no growth.
    function copyTargetContainsSource() external returns (uint256 memoryGrowth, uint256 check) {
        recTarget = recSource;
        recTarget.children[0].children.push();
        recTarget.children[0].children[0].balance = 42;
        uint256 before = allocated();
        recTarget = recTarget.children[0]; // target contains source
        memoryGrowth = allocated() - before;
        check = recTarget.children[0].balance;
    }
}
// ----
// setUp() ->
// gas irOptimized: 474555
// gas legacy: 474446
// gas legacyOptimized: 471535
// gas ssaCFGOptimized: 474771
// copyRecursive() -> 0, 8
// gas irOptimized: 302153
// gas legacy: 311024
// gas legacyOptimized: 302509
// gas ssaCFGOptimized: 302038
// copyFlat() -> 0, 8
// gas irOptimized: 299370
// gas legacy: 309978
// gas legacyOptimized: 299710
// gas ssaCFGOptimized: 299381
// copyRecursiveTwice() -> 0, 0
// gas irOptimized: 118292
// gas legacy: 138603
// gas legacyOptimized: 119205
// gas ssaCFGOptimized: 117704
// copyViaPointer() -> 0, 8
// gas irOptimized: 106570
// gas legacy: 116430
// gas legacyOptimized: 107071
// gas ssaCFGOptimized: 106292
// copyTargetContainsSource() -> 0, 42
// gas irOptimized: 149123
// gas legacy: 166950
// gas legacyOptimized: 149732
// gas ssaCFGOptimized: 148895
