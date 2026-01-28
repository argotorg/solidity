object "C" {
    code {}

    object "C_deployed" {
        code {
            sstore(0, loadimmutable("1"))
        }
    }
}
// ====
// bytecodeFormat: legacy
// ----
// CodeGenerationError 1284: Some immutables were read from but never assigned, possibly because of optimization.
