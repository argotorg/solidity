object "a" {
    code {
        pop(call(address(), 0, 0, 10))
        pop(staticcall(address(), 0, 0))
        pop(delegatecall(address(), 0, 0))
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 9132: (36-40): The "call" instruction is only available in legacy bytecode VMs (you are currently compiling to EOF).
// TypeError 3950: (36-61): Expected expression to evaluate to one value, but got 0 values instead.
// TypeError 9132: (75-85): The "staticcall" instruction is only available in legacy bytecode VMs (you are currently compiling to EOF).
// TypeError 3950: (75-102): Expected expression to evaluate to one value, but got 0 values instead.
// TypeError 9132: (116-128): The "delegatecall" instruction is only available in legacy bytecode VMs (you are currently compiling to EOF).
// TypeError 3950: (116-145): Expected expression to evaluate to one value, but got 0 values instead.
