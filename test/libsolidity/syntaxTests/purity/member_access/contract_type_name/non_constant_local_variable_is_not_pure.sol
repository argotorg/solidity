contract C {
    uint v = 1;
    function foo() pure private {
        C.v;
    }
}

// ----
// TypeError 2527: (71-74): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
