contract C {
    function (uint32, bool) external returns (address, int16) callback;
    constructor(uint8, bool) {}
    modifier m(uint80) { _; }
    function empty() external pure {}
    function one(uint64 value) external pure m(value) returns (bool) { return false; }
    function multiple(uint32, bool) external pure returns (address, int16) { return (address(0), 0); }
    function unused(uint200) internal pure returns (uint208) { return 0; }
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
//     "t_function_external_nonpayable$_t_uint32_$_t_bool_$returns$_t_address_$_t_int16_$": {
//         "contains": {
//             "parameters": {
//                 "type": {
//                     "id": "t_tuple$_t_uint32_$_t_bool_$"
//                 }
//             },
//             "returns": {
//                 "type": {
//                     "id": "t_tuple$_t_address_$_t_int16_$"
//                 }
//             }
//         },
//         "external": true,
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
//     "t_tuple$_t_address_$_t_int16_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_address"
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
//     "t_tuple$_t_bool_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_bool"
//                 }
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_tuple$_t_uint32_$_t_bool_$": {
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
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_tuple$_t_uint64_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_uint64"
//                 }
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_tuple$_t_uint80_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_uint80"
//                 }
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_tuple$_t_uint8_$_t_bool_$": {
//         "contains": [
//             {
//                 "type": {
//                     "id": "t_uint8"
//                 }
//             },
//             {
//                 "type": {
//                     "id": "t_bool"
//                 }
//             }
//         ],
//         "kind": "tuple"
//     },
//     "t_uint32": {
//         "bits": 32,
//         "kind": "uint"
//     },
//     "t_uint64": {
//         "bits": 64,
//         "kind": "uint"
//     },
//     "t_uint8": {
//         "bits": 8,
//         "kind": "uint"
//     },
//     "t_uint80": {
//         "bits": 80,
//         "kind": "uint"
//     }
// }
