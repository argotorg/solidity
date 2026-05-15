==== Source: Error.sol ====

error ErGlobal(uint);

contract E {
    error Er(uint);
}

==== Source: C.sol ====
import * as EMod from "Error.sol";

error ErGlobal(uint);

contract Base {
    error ErBase(uint);
}

contract C is Base {
    error Er(uint);

    uint constant g_error = 1;

    function test1() pure private {
        revert EMod.ErGlobal(g_error);
    }
    function test2() pure private {
        revert EMod.E.Er(g_error);
    }
    function test3() pure private {
        revert ErGlobal(g_error);
    }
    function test4() pure private {
        revert Er(g_error);
    }
    function test5() pure private {
        revert C.Er(g_error);
    }
    function test6() pure private {
        revert ErBase(g_error);
    }
    function test7() pure private {
        revert Base.ErBase(g_error);
    }
}