{
    pop(extcall(address(), 0, 0, 0))
    pop(extdelegatecall(address(), 0, 0))
    pop(extstaticcall(address(), 0, 0))
}
// ====
// bytecodeFormat: legacy
// ----
// TypeError 4328: (10-17): The "extcall" instruction is only available in EOF.
// TypeError 3950: (10-37): Expected expression to evaluate to one value, but got 0 values instead.
// TypeError 4328: (47-62): The "extdelegatecall" instruction is only available in EOF.
// TypeError 3950: (47-79): Expected expression to evaluate to one value, but got 0 values instead.
// TypeError 4328: (89-102): The "extstaticcall" instruction is only available in EOF.
// TypeError 3950: (89-119): Expected expression to evaluate to one value, but got 0 values instead.
