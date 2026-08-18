/// @use-src 1:"test/externalTests/solc-js/DAO/Token.sol"
object "Token_770" {
    code {
        {
            /// @src 1:3766:5816
            let _1 := memoryguard(0x80)
            mstore(64, _1)
            if callvalue() { revert(0, 0) }
            let _2 := sload(/** @src 1:1551:1562 */ 0x05)
            /// @src 1:3766:5816
            let length := /** @src -1:-1:-1 */ 0
            /// @src 1:3766:5816
            length := shr(1, _2)
            let outOfPlaceEncoding := and(_2, 1)
            if iszero(outOfPlaceEncoding) { length := and(length, 0x7f) }
            if eq(outOfPlaceEncoding, lt(length, 32))
            {
                mstore(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ shl(224, 0x4e487b71))
                mstore(4, 0x22)
                revert(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ 0x24)
            }
            if gt(length, 31)
            {
                if gt(length, 9)
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 1:1551:1562 */ 0x05)
                    /// @src 1:3766:5816
                    let data := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ 32)
                    let oldSlotCount := shr(/** @src 1:1551:1562 */ 0x05, /** @src 1:3766:5816 */ add(length, 31))
                    let i := /** @src -1:-1:-1 */ 0
                    /// @src 1:3766:5816
                    for { } lt(i, oldSlotCount) { i := add(i, 1) }
                    {
                        sstore(add(data, i), /** @src -1:-1:-1 */ 0)
                    }
                }
            }
            /// @src 1:3766:5816
            sstore(/** @src 1:1551:1562 */ 0x05, /** @src 1:3766:5816 */ add("Token 0.1", 18))
            let _3 := datasize("Token_770_deployed")
            codecopy(_1, dataoffset("Token_770_deployed"), _3)
            return(_1, _3)
        }
    }
    /// @use-src 1:"test/externalTests/solc-js/DAO/Token.sol"
    object "Token_770_deployed" {
        code {
            {
                /// @src 1:3766:5816
                mstore(64, memoryguard(0x80))
                if iszero(lt(calldatasize(), 4))
                {
                    let _1 := 0
                    switch shr(224, calldataload(0))
case 0x06fdde03 { sstore(0, 1) }
case 0x095ea7b3 { sstore(0, 1) }
case 0x18160ddd { sstore(0, 1) }
case 0x23b872dd { sstore(0, 1) }
case 0x313ce567 { sstore(0, 1) }
case 0x5a3b7e42 { sstore(0, 1) }

                    case 0xdd62ed3e {
                        if callvalue() { revert(_1, _1) }
                        if slt(add(calldatasize(), not(3)), 64) { revert(_1, _1) }
                        let value0_4 := abi_decode_address()
                        let value1_1 := abi_decode_t_address()
                        mstore(_1, and(value0_4, sub(shl(160, 1), 1)))
                        mstore(32, /** @src 1:5782:5789 */ 0x01)
                        /// @src 1:3766:5816
                        let dataSlot_4 := keccak256(_1, 64)
                        /// @src 1:5782:5807
                        let dataSlot_5 := /** @src -1:-1:-1 */ 0
                        /// @src 1:3766:5816
                        mstore(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ and(value1_1, sub(shl(160, 1), 1)))
                        mstore(0x20, /** @src 1:5782:5797 */ dataSlot_4)
                        /// @src 1:3766:5816
                        dataSlot_5 := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ 0x40)
                        let _8 := sload(/** @src 1:5782:5807 */ dataSlot_5)
                        /// @src 1:3766:5816
                        let memPos_10 := mload(64)
                        mstore(memPos_10, _8)
                        return(memPos_10, 32)
                    }
                }
                revert(0, 0)
            }
            function finalize_allocation(memPtr, size)
            {
                let newFreePtr := add(memPtr, and(add(size, 31), not(31)))
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr))
                {
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ shl(224, 0x4e487b71))
                    mstore(4, 0x41)
                    revert(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ 0x24)
                }
                mstore(64, newFreePtr)
            }
            function abi_encode_string(value, pos) -> end
            {
                let length := mload(value)
                mstore(pos, length)
                mcopy(add(pos, 0x20), add(value, 0x20), length)
                mstore(add(add(pos, length), 0x20), /** @src -1:-1:-1 */ 0)
                /// @src 1:3766:5816
                end := add(add(pos, and(add(length, 31), not(31))), 0x20)
            }
            function abi_decode_address() -> value
            {
                value := calldataload(4)
                if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
            }
            function abi_decode_t_address() -> value
            {
                value := calldataload(36)
                if iszero(eq(value, and(value, sub(shl(160, 1), 1)))) { revert(0, 0) }
            }
            function checked_add_uint256(x, y) -> sum
            {
                sum := add(x, y)
                if gt(x, sum)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
            }
            function checked_sub_uint256(x, y) -> diff
            {
                diff := sub(x, y)
                if gt(diff, x)
                {
                    mstore(0, shl(224, 0x4e487b71))
                    mstore(4, 0x11)
                    revert(0, 0x24)
                }
            }
            /// @src 1:4490:5020
            function fun_transferFrom(var_from, var__to, var_amount) -> var_success
            {
                /// @src 1:4620:4632
                var_success := /** @src 1:3766:5816 */ 0
                let _1 := and(var_from, sub(shl(160, 1), 1))
                mstore(0, _1)
                mstore(0x20, 0)
                /// @src 1:4649:4728
                let expr := /** @src 1:4649:4675 */ iszero(lt(/** @src 1:3766:5816 */ sload(keccak256(0, 0x40)), /** @src 1:4649:4675 */ var_amount))
                /// @src 1:4649:4728
                if expr
                {
                    /// @src 1:3766:5816
                    mstore(0, _1)
                    mstore(0x20, /** @src 1:4691:4698 */ 0x01)
                    /// @src 1:3766:5816
                    let dataSlot := keccak256(0, 0x40)
                    /// @src 1:4691:4717
                    let dataSlot_1 := /** @src -1:-1:-1 */ 0
                    /// @src 1:3766:5816
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ and(/** @src 1:4706:4716 */ caller(), /** @src 1:3766:5816 */ sub(shl(160, 1), 1)))
                    mstore(0x20, /** @src 1:4691:4717 */ dataSlot)
                    /// @src 1:3766:5816
                    dataSlot_1 := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ 0x40)
                    /// @src 1:4649:4728
                    expr := /** @src 1:4691:4728 */ iszero(lt(/** @src 1:3766:5816 */ sload(/** @src 1:4691:4717 */ dataSlot_1), /** @src 1:4691:4728 */ var_amount))
                }
                /// @src 1:4649:4755
                let expr_1 := expr
                if expr
                {
                    expr_1 := /** @src 1:4744:4755 */ iszero(iszero(var_amount))
                }
                /// @src 1:4645:5014
                switch expr_1
                case 0 {
                    /// @src 1:4991:5003
                    var_success := /** @src 1:3766:5816 */ 0
                    /// @src 1:4991:5003
                    leave
                }
                default /// @src 1:4645:5014
                {
                    /// @src 1:3766:5816
                    let _2 := and(var__to, sub(shl(160, 1), 1))
                    mstore(0, _2)
                    mstore(0x20, 0)
                    let dataSlot_2 := keccak256(0, 0x40)
                    sstore(dataSlot_2, /** @src 1:4772:4796 */ checked_add_uint256(/** @src 1:3766:5816 */ sload(/** @src 1:4772:4796 */ dataSlot_2), var_amount))
                    /// @src 1:3766:5816
                    mstore(0, _1)
                    mstore(0x20, 0)
                    let dataSlot_3 := keccak256(0, 0x40)
                    sstore(dataSlot_3, /** @src 1:4810:4836 */ checked_sub_uint256(/** @src 1:3766:5816 */ sload(/** @src 1:4810:4836 */ dataSlot_3), var_amount))
                    /// @src 1:3766:5816
                    mstore(0, _1)
                    mstore(0x20, /** @src 1:4850:4857 */ 0x01)
                    /// @src 1:3766:5816
                    let dataSlot_4 := keccak256(0, 0x40)
                    /// @src 1:4850:4876
                    let dataSlot_5 := /** @src -1:-1:-1 */ 0
                    /// @src 1:3766:5816
                    mstore(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ and(/** @src 1:4865:4875 */ caller(), /** @src 1:3766:5816 */ sub(shl(160, 1), 1)))
                    mstore(0x20, /** @src 1:4850:4876 */ dataSlot_4)
                    /// @src 1:3766:5816
                    dataSlot_5 := keccak256(/** @src -1:-1:-1 */ 0, /** @src 1:3766:5816 */ 0x40)
                    sstore(/** @src 1:4850:4876 */ dataSlot_5, /** @src 1:4850:4887 */ checked_sub_uint256(/** @src 1:3766:5816 */ sload(/** @src 1:4850:4876 */ dataSlot_5), /** @src 1:4850:4887 */ var_amount))
                    /// @src 1:4906:4935
                    let _3 := /** @src 1:3766:5816 */ mload(0x40)
                    mstore(_3, var_amount)
                    /// @src 1:4906:4935
                    log3(_3, /** @src 1:3766:5816 */ 0x20, /** @src 1:4906:4935 */ 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, _1, _2)
                    /// @src 1:4949:4960
                    var_success := /** @src 1:4850:4857 */ 0x01
                    /// @src 1:4949:4960
                    leave
                }
            }
            /// @src 1:4107:4484
            function fun_transfer(var_to, var__amount) -> var_success
            {
                /// @src 1:4188:4200
                var_success := /** @src 1:3766:5816 */ 0
                mstore(0, /** @src 1:4225:4235 */ caller())
                /// @src 1:3766:5816
                mstore(0x20, 0)
                /// @src 1:4216:4262
                let expr := /** @src 1:4216:4247 */ iszero(lt(/** @src 1:3766:5816 */ sload(keccak256(0, 0x40)), /** @src 1:4216:4247 */ var__amount))
                /// @src 1:4216:4262
                if expr
                {
                    expr := /** @src 1:4251:4262 */ iszero(iszero(var__amount))
                }
                /// @src 1:4212:4478
                switch expr
                case 0 {
                    /// @src 1:4455:4467
                    var_success := /** @src 1:3766:5816 */ 0
                    /// @src 1:4455:4467
                    leave
                }
                default /// @src 1:4212:4478
                {
                    /// @src 1:3766:5816
                    mstore(0, /** @src 1:4225:4235 */ caller())
                    /// @src 1:3766:5816
                    mstore(0x20, 0)
                    let dataSlot := keccak256(0, 0x40)
                    sstore(dataSlot, /** @src 1:4278:4309 */ checked_sub_uint256(/** @src 1:3766:5816 */ sload(/** @src 1:4278:4309 */ dataSlot), var__amount))
                    /// @src 1:3766:5816
                    let _1 := and(var_to, sub(shl(160, 1), 1))
                    mstore(0, _1)
                    mstore(0x20, 0)
                    let dataSlot_1 := keccak256(0, 0x40)
                    sstore(dataSlot_1, /** @src 1:4323:4347 */ checked_add_uint256(/** @src 1:3766:5816 */ sload(/** @src 1:4323:4347 */ dataSlot_1), var__amount))
                    /// @src 1:4366:4400
                    let _2 := /** @src 1:3766:5816 */ mload(0x40)
                    mstore(_2, var__amount)
                    /// @src 1:4366:4400
                    log3(_2, /** @src 1:3766:5816 */ 0x20, /** @src 1:4366:4400 */ 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, /** @src 1:4225:4235 */ caller(), /** @src 1:4366:4400 */ _1)
                    /// @src 1:4414:4425
                    var_success := /** @src 1:4421:4425 */ 0x01
                    /// @src 1:4414:4425
                    leave
                }
            }
        }
        data ".metadata" hex"a2646970667358221220a37329850f802347567f54193e65af21e3f741dfe66233491ab92be41734534664736f6c637828302e382e33372d646576656c6f702e323032362e382e31322b636f6d6d69742e38313564363134370059"
    }
}
// ====
// EVMVersion: =current
// stackOptimization: true
// ----
//     /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//   0x80
//   dup1
//   0x40
//   mstore
//   jumpi(tag_1, callvalue)
// tag_2:
//     /* "test/externalTests/solc-js/DAO/Token.sol":1551:1562   */
//   0x05
//     /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//   sload
//   pop(0x00)
//   0x01
//   dup2
//   dup2
//   shr
//   swap2
//   and
//   dup1
//   iszero
//   tag_3
//   jumpi
// tag_4:
//   0x20
//   dup3
//   lt
//   swap1
//   eq
//   tag_5
//   jumpi
// tag_6:
//   0x1f
//   dup2
//   gt
//   tag_7
//   jumpi
// tag_8:
//   pop
//   add(0x546f6b656e20302e310000000000000000000000000000000000000000000000, 0x12)
//     /* "test/externalTests/solc-js/DAO/Token.sol":1551:1562   */
//   0x05
//     /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//   sstore
//   dataSize(sub_0)
//   swap1
//   dup2
//   dataOffset(sub_0)
//   dup3
//   codecopy
//   return
// tag_7:
//   0x09
//   dup2
//   gt
//   tag_9
//   jumpi
// tag_10:
//   jump(tag_8)
// tag_9:
//     /* "test/externalTests/solc-js/DAO/Token.sol":1551:1562   */
//   0x05
//   0x00
//     /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//   mstore
//   0x1f
//   keccak256(0x00, 0x20)
//   swap2
//   add
//     /* "test/externalTests/solc-js/DAO/Token.sol":1551:1562   */
//   0x05
//     /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//   shr
//   swap1
//   0x00
// tag_11:
//   dup3
//   dup2
//   lt
//   tag_12
//   jumpi
// tag_13:
//   pop
//   pop
//   jump(tag_10)
// tag_12:
//   dup1
//   0x00
//   0x01
//   swap3
//   dup5
//   add
//   sstore
//   add
//   jump(tag_11)
// tag_5:
//   mstore(0x00, shl(0xe0, 0x4e487b71))
//   mstore(0x04, 0x22)
//   revert(0x00, 0x24)
// tag_3:
//   swap1
//   0x7f
//   swap1
//   and
//   swap1
//   jump(tag_4)
// tag_1:
//   0x00
//   dup1
//   revert
// stop
//
// sub_0: assembly {
//         /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//       mstore(0x40, 0x80)
//       jumpi(tag_3, iszero(lt(calldatasize, 0x04)))
//     tag_4:
//       0x00
//       dup1
//       revert
//     tag_3:
//       0x00
//       shr(0xe0, calldataload(0x00))
//       swap1
//       0x23b872dd
//       dup3
//       gt
//       tag_5
//       jumpi
//     tag_6:
//       pop
//       dup1
//       0x06fdde03
//       eq
//       tag_7
//       jumpi
//     tag_8:
//       dup1
//       0x095ea7b3
//       eq
//       tag_9
//       jumpi
//     tag_10:
//       dup1
//       0x18160ddd
//       eq
//       tag_11
//       jumpi
//     tag_12:
//       0x23b872dd
//       eq
//       tag_13
//       jumpi
//     tag_14:
//     tag_15:
//       jump(tag_4)
//     tag_13:
//       sstore(0x00, 0x01)
//       jump(tag_15)
//     tag_11:
//       pop
//       sstore(0x00, 0x01)
//       jump(tag_15)
//     tag_9:
//       pop
//       sstore(0x00, 0x01)
//       jump(tag_15)
//     tag_7:
//       pop
//       sstore(0x00, 0x01)
//       jump(tag_15)
//     tag_5:
//       swap1
//       dup1
//       0x313ce567
//       eq
//       tag_16
//       jumpi
//     tag_17:
//       dup1
//       0x5a3b7e42
//       eq
//       tag_18
//       jumpi
//     tag_19:
//       0xdd62ed3e
//       eq
//       tag_20
//       jumpi
//     tag_21:
//       pop
//       jump(tag_15)
//     tag_20:
//       jumpi(tag_22, callvalue)
//     tag_23:
//       jumpi(tag_24, slt(add(calldatasize, not(0x03)), 0x40))
//     tag_25:
//       0x40
//       tag_26
//       tag_1
//       jump	// in
//     tag_26:
//       swap2
//       tag_27
//       tag_2
//       jump	// in
//     tag_27:
//       swap3
//       0x01
//       dup1
//       0xa0
//       shl
//       sub
//       swap1
//       and
//       dup2
//       mstore
//         /* "test/externalTests/solc-js/DAO/Token.sol":5782:5789   */
//       0x01
//         /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//       0x20
//       mstore
//       keccak256
//         /* "test/externalTests/solc-js/DAO/Token.sol":5782:5807   */
//       swap1
//       0x00
//         /* "test/externalTests/solc-js/DAO/Token.sol":3766:5816   */
//       pop
//       0x01
//       dup1
//       0xa0
//       shl
//       sub
//       swap1
//       and
//       0x00
//       mstore
//       0x20
//       mstore
//       0x20
//       sload(keccak256(0x00, 0x40))
//       mload(0x40)
//       swap1
//       dup2
//       mstore
//       return
//     tag_24:
//       dup1
//       revert
//     tag_22:
//       dup1
//       revert
//     tag_18:
//       pop
//       pop
//       sstore(0x00, 0x01)
//       jump(tag_15)
//     tag_16:
//       pop
//       pop
//       sstore(0x00, 0x01)
//       jump(tag_15)
//     tag_1:
//       calldataload(0x04)
//       swap1
//       0x01
//       dup1
//       0xa0
//       shl
//       sub
//       dup3
//       and
//       dup3
//       eq
//       iszero
//       tag_28
//       jumpi
//     tag_29:
//       jump	// out
//     tag_28:
//       0x00
//       dup1
//       revert
//     tag_2:
//       calldataload(0x24)
//       swap1
//       0x01
//       dup1
//       0xa0
//       shl
//       sub
//       dup3
//       and
//       dup3
//       eq
//       iszero
//       tag_30
//       jumpi
//     tag_31:
//       jump	// out
//     tag_30:
//       0x00
//       dup1
//       revert
//
//     auxdata: 0xa2646970667358221220a37329850f802347567f54193e65af21e3f741dfe66233491ab92be41734534664736f6c637828302e382e33372d646576656c6f702e323032362e382e31322b636f6d6d69742e38313564363134370059
// }
