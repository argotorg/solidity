object "a" {
    code {
        mstore(0, auxdataloadn(0))
        return(0, 32)
    }

    data "data1" "Hello, World!"
}

// ====
// EVMVersion: >=prague
// bytecodeFormat: legacy
// ----
// DeclarationError 7223: (42-54): Builtin function "auxdataloadn" is only available in EOF.
// TypeError 3950: (42-57): Expected expression to evaluate to one value, but got 0 values instead.
