contract B {}

contract C {
    function f() public view {
        B b;
        assembly {
            b := eofcreate(B.objectName, 0, 0, 0, 0)
        }
    }

    function g() public pure {
        B b;
        assembly {
            b := eofcreate(B.objectName, 0, 0, 0, 0)
        }
    }

}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 8961: (108-143): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (241-276): Function cannot be declared as pure because this expression (potentially) modifies the state.
