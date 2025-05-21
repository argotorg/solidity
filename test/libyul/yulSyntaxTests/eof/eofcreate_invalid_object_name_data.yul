object "a" {
    code {
        mstore(0, eofcreate("data1", 0, 0, 0, 0))
        return(0, 32)
    }

    data "data1" "Hello, World!"
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// ----
// TypeError 7575: (52-59): Data name "data1" cannot be used as an argument of eofcreate/returncontract. Only an object name is acceptable.
