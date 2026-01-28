object "a" {
    code {
        pop(extcodehash(0))
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 9132: (36-47): The "extcodehash" instruction is only available in legacy bytecode VMs (you are currently compiling to EOF).
// TypeError 3950: (36-50): Expected expression to evaluate to one value, but got 0 values instead.
