struct Point { uint8 x; uint8 y; }
struct Wide { uint256 a; uint128 b; uint256 c; }

contract C {
    uint16[8] packed;
    uint256[3] words;
    uint128[3] halves;
    bytes32[2][2] grid;
    Point[2] points;
    Wide[2] wides;
}
// ----
// .resources.types | keys: ["t_array$_t_array$_t_bytes32_$2_storage_$2_storage","t_array$_t_bytes32_$2_storage","t_array$_t_struct$_Point_$6_storage_$2_storage","t_array$_t_struct$_Wide_$13_storage_$2_storage","t_array$_t_uint128_$3_storage","t_array$_t_uint16_$8_storage","t_array$_t_uint256_$3_storage","t_bytes32","t_struct$_Point_$6_storage","t_struct$_Wide_$13_storage","t_uint128","t_uint16","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_array$_t_array$_t_bytes32_$2_storage_$2_storage","storage-t_array$_t_bytes32_$2_storage","storage-t_array$_t_struct$_Point_$6_storage_$2_storage","storage-t_array$_t_struct$_Wide_$13_storage_$2_storage","storage-t_array$_t_uint128_$3_storage","storage-t_array$_t_uint16_$8_storage","storage-t_array$_t_uint256_$3_storage","storage-t_bytes32","storage-t_struct$_Point_$6_storage","storage-t_struct$_Wide_$13_storage","storage-t_uint128","storage-t_uint16","storage-t_uint256","storage-t_uint8"]
// .resources.pointers.storage-t_array$_t_array$_t_bytes32_$2_storage_$2_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "list": {
//             "count": "0x02",
//             "each": "index",
//             "is": {
//                 "define": {
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             {
//                                 "~product": [
//                                     "index",
//                                     "0x02"
//                                 ]
//                             }
//                         ]
//                     }
//                 },
//                 "in": {
//                     "template": "storage-t_array$_t_bytes32_$2_storage",
//                     "yields": {
//                         "item": "item-item"
//                     }
//                 }
//             }
//         }
//     }
// }
// .resources.pointers.storage-t_array$_t_bytes32_$2_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "list": {
//             "count": "0x02",
//             "each": "index",
//             "is": {
//                 "location": "storage",
//                 "name": "item",
//                 "slot": {
//                     "~sum": [
//                         "slot",
//                         "index"
//                     ]
//                 }
//             }
//         }
//     }
// }
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$2_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "list": {
//             "count": "0x02",
//             "each": "index",
//             "is": {
//                 "define": {
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "index"
//                         ]
//                     }
//                 },
//                 "in": {
//                     "template": "storage-t_struct$_Point_$6_storage",
//                     "yields": {
//                         "x": "item-x",
//                         "y": "item-y"
//                     }
//                 }
//             }
//         }
//     }
// }
// .resources.pointers.storage-t_array$_t_struct$_Wide_$13_storage_$2_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "list": {
//             "count": "0x02",
//             "each": "index",
//             "is": {
//                 "define": {
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             {
//                                 "~product": [
//                                     "index",
//                                     "0x03"
//                                 ]
//                             }
//                         ]
//                     }
//                 },
//                 "in": {
//                     "template": "storage-t_struct$_Wide_$13_storage",
//                     "yields": {
//                         "a": "item-a",
//                         "b": "item-b",
//                         "c": "item-c"
//                     }
//                 }
//             }
//         }
//     }
// }
// .resources.pointers.storage-t_array$_t_uint128_$3_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "list": {
//             "count": "0x03",
//             "each": "index",
//             "is": {
//                 "length": "0x10",
//                 "location": "storage",
//                 "name": "item",
//                 "offset": {
//                     "~difference": [
//                         "~wordsize",
//                         {
//                             "~product": [
//                                 {
//                                     "~sum": [
//                                         {
//                                             "~remainder": [
//                                                 "index",
//                                                 "0x02"
//                                             ]
//                                         },
//                                         "0x01"
//                                     ]
//                                 },
//                                 "0x10"
//                             ]
//                         }
//                     ]
//                 },
//                 "slot": {
//                     "~sum": [
//                         "slot",
//                         {
//                             "~quotient": [
//                                 "index",
//                                 "0x02"
//                             ]
//                         }
//                     ]
//                 }
//             }
//         }
//     }
// }
// .resources.pointers.storage-t_array$_t_uint16_$8_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "list": {
//             "count": "0x08",
//             "each": "index",
//             "is": {
//                 "length": "0x02",
//                 "location": "storage",
//                 "name": "item",
//                 "offset": {
//                     "~difference": [
//                         "~wordsize",
//                         {
//                             "~product": [
//                                 {
//                                     "~sum": [
//                                         {
//                                             "~remainder": [
//                                                 "index",
//                                                 "0x10"
//                                             ]
//                                         },
//                                         "0x01"
//                                     ]
//                                 },
//                                 "0x02"
//                             ]
//                         }
//                     ]
//                 },
//                 "slot": {
//                     "~sum": [
//                         "slot",
//                         {
//                             "~quotient": [
//                                 "index",
//                                 "0x10"
//                             ]
//                         }
//                     ]
//                 }
//             }
//         }
//     }
// }
// .resources.pointers.storage-t_array$_t_uint256_$3_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "list": {
//             "count": "0x03",
//             "each": "index",
//             "is": {
//                 "location": "storage",
//                 "name": "item",
//                 "slot": {
//                     "~sum": [
//                         "slot",
//                         "index"
//                     ]
//                 }
//             }
//         }
//     }
// }
// .resources.pointers.storage-t_struct$_Point_$6_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "group": [
//             {
//                 "length": "0x01",
//                 "location": "storage",
//                 "name": "x",
//                 "offset": "0x1f",
//                 "slot": "slot"
//             },
//             {
//                 "length": "0x01",
//                 "location": "storage",
//                 "name": "y",
//                 "offset": "0x1e",
//                 "slot": "slot"
//             }
//         ]
//     }
// }
// .resources.pointers.storage-t_struct$_Wide_$13_storage: {
//     "expect": [
//         "slot"
//     ],
//     "for": {
//         "group": [
//             {
//                 "location": "storage",
//                 "name": "a",
//                 "slot": "slot"
//             },
//             {
//                 "length": "0x10",
//                 "location": "storage",
//                 "name": "b",
//                 "offset": "0x10",
//                 "slot": {
//                     "~sum": [
//                         "slot",
//                         "0x01"
//                     ]
//                 }
//             },
//             {
//                 "location": "storage",
//                 "name": "c",
//                 "slot": {
//                     "~sum": [
//                         "slot",
//                         "0x02"
//                     ]
//                 }
//             }
//         ]
//     }
// }
// .resources.types.t_struct$_Wide_$13_storage: {
//     "contains": [
//         {
//             "name": "a",
//             "type": {
//                 "id": "t_uint256"
//             }
//         },
//         {
//             "name": "b",
//             "type": {
//                 "id": "t_uint128"
//             }
//         },
//         {
//             "name": "c",
//             "type": {
//                 "id": "t_uint256"
//             }
//         }
//     ],
//     "definition": {
//         "location": {
//             "range": {
//                 "length": 48,
//                 "offset": 94
//             },
//             "source": {
//                 "id": 0,
//                 "type": "source"
//             }
//         },
//         "name": "Wide"
//     },
//     "kind": "struct"
// }
