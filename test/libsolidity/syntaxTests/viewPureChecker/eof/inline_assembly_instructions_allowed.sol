contract C {
    function f() public {
        assembly {
            stop()
            pop(add(0, 1))
            pop(sub(0, 1))
            pop(mul(0, 1))
            pop(div(0, 1))
            pop(sdiv(0, 1))
            pop(mod(0, 1))
            pop(smod(0, 1))
            pop(exp(0, 1))
            pop(not(0))
            pop(lt(0, 1))
            pop(gt(0, 1))
            pop(slt(0, 1))
            pop(sgt(0, 1))
            pop(eq(0, 1))
            pop(iszero(0))
            pop(and(0, 1))
            pop(or(0, 1))
            pop(xor(0, 1))
            pop(byte(0, 1))
            pop(shl(0, 1))
            pop(shr(0, 1))
            pop(sar(0, 1))
            pop(addmod(0, 1, 2))
            pop(mulmod(0, 1, 2))
            pop(signextend(0, 1))
            pop(keccak256(0, 1))
            pop(0)
            pop(mload(0))
            mstore(0, 1)
            mstore8(0, 1)
            pop(sload(0))
            sstore(0, 1)
            pop(address())
            pop(balance(0))
            pop(selfbalance())
            pop(caller())
            pop(callvalue())
            pop(calldataload(0))
            pop(calldatasize())
            calldatacopy(0, 1, 2)
            pop(returndatasize())
            returndatacopy(0, 1, 2)
            pop(extcall(0, 1, 2, 3))
            pop(extdelegatecall(0, 1, 2))
            pop(extstaticcall(0, 1, 2))
            return(0, 1)
            revert(0, 1)
            invalid()
            log0(0, 1)
            log1(0, 1, 2)
            log2(0, 1, 2, 3)
            log3(0, 1, 2, 3, 4)
            log4(0, 1, 2, 3, 4, 5)
            pop(chainid())
            pop(basefee())
            pop(origin())
            pop(gasprice())
            pop(blockhash(0))
            pop(coinbase())
            pop(timestamp())
            pop(number())
            pop(prevrandao())

            mcopy(1, 2, 3)
            pop(blobhash(0))
            pop(blobbasefee())
            pop(tload(0))
            tstore(0, 0)

            // NOTE: msize() is allowed only with optimizer disabled
            //pop(msize())
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// Warning 2394: (1970-1976): Transient storage as defined by EIP-1153 can break the composability of smart contracts: Since transient storage is cleared only at the end of the transaction and not at the end of the outermost call frame to the contract within a transaction, your contract may unintentionally misbehave when invoked multiple times in a complex transaction. To avoid this, be sure to clear all transient storage at the end of any call to your contract. The use of transient storage for reentrancy guards that are cleared at the end of the call is safe.
// Warning 5740: (89-1400): Unreachable code.
// Warning 5740: (1413-1425): Unreachable code.
// Warning 5740: (1438-1447): Unreachable code.
// Warning 5740: (1460-1982): Unreachable code.
