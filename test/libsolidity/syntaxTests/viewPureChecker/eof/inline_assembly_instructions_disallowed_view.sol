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

            // This one is disallowed too but the error suppresses other errors.
            //pop(msize())
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 8961: (75-87): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (104-123): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (141-165): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (179-189): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (202-215): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (228-244): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (257-276): Function cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (289-311): Function cannot be declared as view because this expression (potentially) modifies the state.
