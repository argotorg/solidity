contract C {
    function f() pure public {
        assembly {
            let x := f.slot
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 9479: (84-90): The suffixes ".offset", ".slot" and ".length" can only be used with variables or the suffix "objectName" can be used with a contract name identifier.
