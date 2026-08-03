contract C {
    address lastCaller;

    constructor() {
        lastCaller = msg.sender;
    }

    modifier log {
        lastCaller = msg.sender;
        _;
    }

    function test() log public {
        assert(lastCaller == msg.sender);
        this.g();
        assert(lastCaller == address(this));
        assert(lastCaller == msg.sender);
        assert(lastCaller == address(0));
    }

    function g() log public {
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (314-346): CHC: Assertion violation happens here.\nCounterexample:\nlastCaller = 0x0\n\nTransaction trace:\nC.constructor(){ msg.sender: 0x0 }\nState: lastCaller = 0x0\nC.test(){ msg.sender: 0xffffffffffffffffffffffffffffffffffffdd68 }\n    C.g() -- trusted external call
// Warning 6328: (356-388): CHC: Assertion violation happens here.\nCounterexample:\nlastCaller = 0x2298\n\nTransaction trace:\nC.constructor(){ msg.sender: 0x0 }\nState: lastCaller = 0x0\nC.test(){ msg.sender: 0x2299 }\n    C.g() -- trusted external call
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
