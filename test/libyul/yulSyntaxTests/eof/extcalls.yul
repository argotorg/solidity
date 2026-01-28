object "a" {
    code {
        pop(extcall(address(), 0, 0, 0))
        pop(extdelegatecall(address(), 0, 0))
        pop(extstaticcall(address(), 0, 0))
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
