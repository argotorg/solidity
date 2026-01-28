type MyBytes is bytes2;

contract C {
    MyBytes b = MyBytes.wrap("ab");

    function check() view public {
        assert(MyBytes.unwrap(b) == 0); // should fail
        assert(MyBytes.unwrap(b) == 0x6162); // should hold
    }
}
// ====
// SMTEngine: chc
// ----
// Warning 6328: (118-148): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.check()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
