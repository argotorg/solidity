contract C {
    modifier guarded(bool enabled) {
        require(enabled);
        _;
    }

    function f(uint256 value, bytes memory payload, uint256[] calldata items, function() external callback)
        external
        guarded(true)
        returns (uint256 result, bytes memory)
    {
        callback();
        return (value + items.length, payload);
    }
}
// ----
// C.semantic.format: solidity-ethdebug-semantic-data
// C.semantic.version: 1
// C.semantic.contractName: C
// C.semantic.scopes | keys: ["11","43"]
// C.semantic.scopes.11.0.variableDefinitions | length: 1
// C.semantic.scopes.11.0.variableDefinitions[0].identifier: enabled
// C.semantic.scopes.11.0.variableDefinitions[0].declarationASTID: 3
// C.semantic.scopes.11.0.variableDefinitions[0].phase: materialized
// C.semantic.scopes.11.0.variableDefinitions[0].pointer: {
//     "location": "stack",
//     "slot": {
//         "~~yulLocal": "var_enabled_3"
//     }
// }
// C.semantic.scopes.11.0.variableDefinitions[0].typeID: t_bool
// C.semantic.scopes.43.0.variableDefinitions | length: 6
// C.semantic.scopes.43.0.variableDefinitions[0].identifier: value
// C.semantic.scopes.43.0.variableDefinitions[0].declarationSourceRange: {
//     "range": {
//         "length": 13,
//         "offset": 168
//     },
//     "source": {
//         "id": 0,
//         "type": "source"
//     }
// }
// C.semantic.scopes.43.0.variableDefinitions[0].pointer: {
//     "location": "stack",
//     "slot": {
//         "~~yulLocal": "var_value_13"
//     }
// }
// C.semantic.scopes.43.0.variableDefinitions[0].typeID: t_uint256
// C.semantic.scopes.43.0.variableDefinitions[1].identifier: payload
// C.semantic.scopes.43.0.variableDefinitions[1].pointer: {
//     "location": "stack",
//     "slot": {
//         "~~yulLocal": "var_payload_15_mpos"
//     }
// }
// C.semantic.scopes.43.0.variableDefinitions[1].typeID: t_bytes_storage
// C.semantic.scopes.43.0.variableDefinitions[2].identifier: items
// C.semantic.scopes.43.0.variableDefinitions[2].pointer: {
//     "group": [
//         {
//             "location": "stack",
//             "name": "offset",
//             "slot": {
//                 "~~yulLocal": "var_items_18_offset"
//             }
//         },
//         {
//             "location": "stack",
//             "name": "length",
//             "slot": {
//                 "~~yulLocal": "var_items_18_length"
//             }
//         }
//     ]
// }
// C.semantic.scopes.43.0.variableDefinitions[2].typeID: t_array$_t_uint256_$dyn_storage
// C.semantic.scopes.43.0.variableDefinitions[3].identifier: callback
// C.semantic.scopes.43.0.variableDefinitions[3].pointer: {
//     "group": [
//         {
//             "location": "stack",
//             "name": "address",
//             "slot": {
//                 "~~yulLocal": "var_callback_22_address"
//             }
//         },
//         {
//             "location": "stack",
//             "name": "functionSelector",
//             "slot": {
//                 "~~yulLocal": "var_callback_22_functionSelector"
//             }
//         }
//     ]
// }
// C.semantic.scopes.43.0.variableDefinitions[3].typeID: t_function_external_nonpayable$__$returns$__$
// C.semantic.scopes.43.0.variableDefinitions[4].identifier: result
// C.semantic.scopes.43.0.variableDefinitions[4].pointer: {
//     "location": "stack",
//     "slot": {
//         "~~yulLocal": "var_result_28"
//     }
// }
// C.semantic.scopes.43.0.variableDefinitions[5].identifier: <PATH NOT FOUND>
// C.semantic.scopes.43.0.variableDefinitions[5].phase: materialized
// C.semantic.scopes.43.0.variableDefinitions[5].pointer: {
//     "location": "stack",
//     "slot": {
//         "~~yulLocal": "var__30_mpos"
//     }
// }
// C.semantic.scopes.43.0.variableDefinitions[5].typeID: t_bytes_storage
// C.semantic.resources.types.t_bytes_storage: {"kind":"bytes"}
// C.semantic.resources.types.t_array$_t_uint256_$dyn_storage.kind: array
