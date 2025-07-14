contract D {
    function test() public pure {
        bytes7[2] memory dummyBytes = [bytes7("A"), "B"];
        assert(uint56(dummyBytes[0]) == 0x41000000000000);
        assert(uint56(dummyBytes[1]) == 0x42000000000000);
        assert(uint56(dummyBytes[1]) == 0x41000000000000); // Should fail
    }
}
// ====
// SMTEngine: chc
// SMTTargets: assert
// ----
// Warning 6328: (231-280): CHC: Assertion violation happens here.\nCounterexample:\n\ndummyBytes = [0x41000000000000, 0x42000000000000]\n\nTransaction trace:\nD.constructor()\nD.test()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
