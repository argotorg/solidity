object "a" {
    code {
        rjump()
        rjumpi()
    }
}
// ====
// bytecodeFormat: legacy,>=EOFv1
// ----
// DeclarationError 4619: (32-37): Function "rjump" not found.
// DeclarationError 4619: (48-54): Function "rjumpi" not found.
