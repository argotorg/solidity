==== Source: ExtCall.sol ====
interface Unknown {
    function callme() external;
}

contract ExtCall {
    uint x;

    bool lock;
    modifier mutex {
        require(!lock);
        lock = true;
        _;
        lock = false;
    }

    function setX(uint y) mutex public {
        x = y;
    }

    function xMut(Unknown u) public {
        uint x_prev = x;
        u.callme();
        assert(x_prev == x);
    }
}
==== Source: ExtCall.t.sol ====
import "ExtCall.sol";

contract ExtCallTest {
    ExtCall call;

    function setUp() public {
        call = new ExtCall();
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (ExtCall.sol:362-381): CHC: Assertion violation happens here.\nCounterexample:\nx = 0, lock = false\nu = 0\nx_prev = 1\n\nTransaction trace:\nExtCall.constructor()\nState: x = 0, lock = false\nExtCall.setX(1)\nState: x = 1, lock = false\nExtCall.xMut(0)\n    u.callme() -- untrusted external call, synthesized as:\n        ExtCall.setX(0) -- reentrant call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 8729: (ExtCall.t.sol:110-123): Contract deployment is only supported in the trusted mode for external calls with the CHC engine.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
