contract C {
    function f() public pure {
        assembly {
            pop(sload(0))
            sstore(0, 1)
            pop(address())
            pop(balance(0))
            pop(caller())
            pop(callvalue())
            pop(extcall(0, 1, 2, 3))
            pop(extstaticcall(0, 1, 2))
            pop(extdelegatecall(0, 1, 2))
            log0(0, 1)
            log1(0, 1, 2)
            log2(0, 1, 2, 3)
            log3(0, 1, 2, 3, 4)
            log4(0, 1, 2, 3, 4, 5)
            pop(origin())
            pop(gasprice())
            pop(blockhash(0))
            pop(coinbase())
            pop(timestamp())
            pop(number())
            pop(gaslimit())
            pop(blobhash(0))
            pop(blobbasefee())
            pop(tload(0))
            tstore(0, 0)
            pop(selfbalance())
            pop(chainid())
            pop(basefee())
            pop(prevrandao())

            // This one is disallowed too but the error suppresses other errors.
            //pop(msize())
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// Warning 2394: (781-787): Transient storage as defined by EIP-1153 can break the composability of smart contracts: Since transient storage is cleared only at the end of the transaction and not at the end of the outermost call frame to the contract within a transaction, your contract may unintentionally misbehave when invoked multiple times in a complex transaction. To avoid this, be sure to clear all transient storage at the end of any call to your contract. The use of transient storage for reentrancy guards that are cleared at the end of the call is safe.
// TypeError 2527: (79-87): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (101-113): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (130-139): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (157-167): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (185-193): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (211-222): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (240-259): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (277-299): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (317-341): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (355-365): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (378-391): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (404-420): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (433-452): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (465-487): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (504-512): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (530-540): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (558-570): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (588-598): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (616-627): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (645-653): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (671-681): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (699-710): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (728-741): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (759-767): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (781-793): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (810-823): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (841-850): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (868-877): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (895-907): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
