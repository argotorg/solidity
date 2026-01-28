object "a" {
    code {
        callf()
        jumpf()
        retf()
    }
}
// ====
// bytecodeFormat: legacy,>=EOFv1
// ----
// DeclarationError 4619: (32-37): Function "callf" not found.
// DeclarationError 4619: (48-53): Function "jumpf" not found.
// DeclarationError 4619: (64-68): Function "retf" not found.
