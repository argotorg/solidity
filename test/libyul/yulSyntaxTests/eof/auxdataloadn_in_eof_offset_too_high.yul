object "a" {
    code {
        {
            mstore(0, auxdataloadn(0xffe0))
            return(0, 32)
        }
    }
    data "data1" hex"48656c6c6f2c20576f726c6421"
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// CodeGenerationError 3965: The highest accessed data offset exceeds the maximum possible size of the static auxdata section.
