contract A {
    bytes3 public a;

    constructor(bytes3 _a) payable {
        a = _a;
    }
}

contract B {
    A a;

    constructor() payable {
        a = (new A){value: 10}("abc");
        assert(a.a() == 0x616263);
    }
}
// ====
// SMTEngine: chc
// SMTExtCalls: trusted
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
