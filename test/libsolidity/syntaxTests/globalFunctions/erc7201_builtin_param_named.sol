contract C {
    uint x = erc7201({namespaceID: "example.main"});
}
// ----
// TypeError 4974: (26-64): Named argument "namespaceID" does not match function declaration.
