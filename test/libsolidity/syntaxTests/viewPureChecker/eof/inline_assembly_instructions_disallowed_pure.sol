contract B {}

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
            pop(eofcreate(B.objectName, 0, 0, 0, 0))

            // This one is disallowed too but the error suppresses other errors.
            //pop(msize())
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// Warning 2394: (796-802): Transient storage as defined by EIP-1153 can break the composability of smart contracts: Since transient storage is cleared only at the end of the transaction and not at the end of the outermost call frame to the contract within a transaction, your contract may unintentionally misbehave when invoked multiple times in a complex transaction. To avoid this, be sure to clear all transient storage at the end of any call to your contract. The use of transient storage for reentrancy guards that are cleared at the end of the call is safe.
// TypeError 2527: (94-102): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (116-128): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (145-154): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (172-182): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (200-208): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (226-237): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (255-274): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (292-314): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (332-356): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (370-380): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (393-406): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (419-435): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (448-467): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 8961: (480-502): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (519-527): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (545-555): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (573-585): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (603-613): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (631-642): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (660-668): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (686-696): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (714-725): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (743-756): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (774-782): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (796-808): Function cannot be declared as pure because this expression (potentially) modifies the state.
// TypeError 2527: (825-838): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (856-865): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (883-892): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (910-922): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (940-975): Function cannot be declared as pure because this expression (potentially) modifies the state.
