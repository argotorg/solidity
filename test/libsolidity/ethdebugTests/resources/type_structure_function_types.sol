contract C {
    function () external externalEmpty;
    function (uint32) external externalNoReturns;
    function () external returns (uint32) externalOneReturn;
    function (uint32) external returns (uint32) externalSingle;
    function (uint32, bool, address) external returns (bytes4, int16) externalMultiple;
    function () internal internalEmpty;
    function (uint32) internal returns (uint32) internalSingle;
    function (uint32, bool, address) internal returns (bytes4, int16) internalMultiple;
}
// ----
// .resources.types: {
//     "t_address": {
//         "kind": "address",
//         "payable": false
//     },
//     "t_bool": {
//         "kind": "bool"
//     },
//     "t_bytes4": {
//         "kind": "bytes",
//         "size": 4
//     },
//     "t_function_external_nonpayable$__$returns$__$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$__$"
//                 }
//             }
//         },
//         "external": true,
//         "kind": "function"
//     },
//     "t_function_external_nonpayable$__$returns$_t_uint32_$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$__$"
//                 }
//             },
//             "returns": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$"
//                 }
//             }
//         },
//         "external": true,
//         "kind": "function"
//     },
//     "t_function_external_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$_t_bool_$_t_address_$"
//                 }
//             },
//             "returns": {
//                 "type": {
//                     "id": "t_tuple$_t_bytes4_$_t_int16_$"
//                 }
//             }
//         },
//         "external": true,
//         "kind": "function"
//     },
//     "t_function_external_nonpayable$_t_uint32_$returns$__$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$"
//                 }
//             }
//         },
//         "external": true,
//         "kind": "function"
//     },
//     "t_function_external_nonpayable$_t_uint32_$returns$_t_uint32_$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$"
//                 }
//             },
//             "returns": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$"
//                 }
//             }
//         },
//         "external": true,
//         "kind": "function"
//     },
//     "t_function_internal_nonpayable$__$returns$__$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$__$"
//                 }
//             }
//         },
//         "internal": true,
//         "kind": "function"
//     },
//     "t_function_internal_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$_t_bool_$_t_address_$"
//                 }
//             },
//             "returns": {
//                 "type": {
//                     "id": "t_tuple$_t_bytes4_$_t_int16_$"
//                 }
//             }
//         },
//         "internal": true,
//         "kind": "function"
//     },
//     "t_function_internal_nonpayable$_t_uint32_$returns$_t_uint32_$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$"
//                 }
//             },
//             "returns": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$"
//                 }
//             }
//         },
//         "internal": true,
//         "kind": "function"
//     },
//     "t_int16": {
//         "bits": 16,
//         "kind": "int"
//     },
//     "t_tuple$__$": {
//         "contains": [],
//         "kind": "tuple"
//     },
//     "t_tuple$_t_bytes4_$_t_int16_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_bytes4"
//                 }
//             },
//             {
//                 "type": {
//                     "id": "t_int16"
//                 }
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_tuple$_t_uint32_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_uint32"
//                 }
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_tuple$_t_uint32_$_t_bool_$_t_address_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_uint32"
//                 }
//             },
//             {
//                 "type": {
//                     "id": "t_bool"
//                 }
//             },
//             {
//                 "type": {
//                     "id": "t_address"
//                 }
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_uint32": {
//         "bits": 32,
//         "kind": "uint"
//     }
// }
