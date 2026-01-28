object "a" {
    code {
        pop(create2(0, 0, 0, 0))
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 9132: (36-43): The "create2" instruction is only available in legacy bytecode VMs (you are currently compiling to EOF).
// TypeError 3950: (36-55): Expected expression to evaluate to one value, but got 0 values instead.
