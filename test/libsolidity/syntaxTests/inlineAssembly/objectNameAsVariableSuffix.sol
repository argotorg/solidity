contract C {
    uint s;
    function f() public {
        uint b;
        assembly {
            b := s.objectName
            b := b.objectName
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 4656: (103-115): State variables only support ".slot" and ".offset".
// TypeError 3622: (133-145): The suffix ".objectName" is not supported by this variable or type.
