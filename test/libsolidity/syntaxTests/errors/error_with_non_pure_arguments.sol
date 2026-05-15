==== Source: C.sol ====
import * as EMod from "Error.sol";

error ErGlobal(uint);

contract Base {
    error ErBase(uint);
}

contract C is Base {
    error Er(uint);

    uint g_error;

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
==== Source: Error.sol ====

error ErGlobal(uint);

contract E {
    error Er(uint);
}

// ----
// TypeError 2527: (C.sol:228-235): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (C.sol:305-312): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (C.sol:381-388): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (C.sol:451-458): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (C.sol:523-530): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (C.sol:597-604): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (C.sol:676-683): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
