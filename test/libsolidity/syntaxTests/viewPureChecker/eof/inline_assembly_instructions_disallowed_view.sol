contract B {}

contract C {
    function f() public view {
        assembly {
            sstore(0, 1)
            pop(extcall(0, 1, 2, 3))
            pop(extdelegatecall(0, 1, 2))
            log0(0, 1)
            log1(0, 1, 2)
            log2(0, 1, 2, 3)
            log3(0, 1, 2, 3, 4)
            log4(0, 1, 2, 3, 4, 5)
            pop(eofcreate(B.objectName, 0, 0, 0, 0))

            // This one is disallowed too but the error suppresses other errors.
            //pop(msize())
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 8961: (90-102): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (119-138): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (156-180): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (194-204): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (217-230): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (243-259): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (272-291): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (304-326): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (343-378): Function cannot be declared as view because this expression (potentially) modifies the state.
