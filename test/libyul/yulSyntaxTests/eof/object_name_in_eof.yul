object "a.b" {
    code {}
}

// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// ----
// SyntaxError 9822: (24-26): The object name "a.b" is invalid in EOF context. Object names must not contain 'dot' character.
