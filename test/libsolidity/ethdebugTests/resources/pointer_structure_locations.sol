type Price is uint64;
enum Color { Red, Green }
struct Point { uint8 x; int16 y; }
struct Record { Point point; uint16[] values; string text; bytes4 tag; }
contract C {
    Record stored;
    uint16 transient temporary;
    Price price;
    Color color;
    function () external callback;
    function () internal internalCallback;
    function inspect(Record calldata input, uint16[2][3] calldata fixedValues, bytes[][2] calldata blobs)
        external pure returns (Record memory result)
    {
        result = input;
        uint16[2][3] memory fixedCopy = fixedValues;
        bytes[][2] memory blobCopy = blobs;
        fixedCopy; blobCopy;
    }
}
// ====
// EVMVersion: >=cancun
// ----
// .resources.pointers.memory-t_struct$_Record_$22_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "group": [
//                     {
//                         "length": "0x20",
//                         "location": "memory",
//                         "name": "point-address",
//                         "offset": "offset"
//                     },
//                     {
//                         "define": {
//                             "offset": {
//                                 "~read": "point-address"
//                             }
//                         },
//                         "in": {
//                             "template": "memory-t_struct$_Point_$11_storage",
//                             "yields": {
//                                 "x": "point-x",
//                                 "y": "point-y"
//                             }
//                         }
//                     }
//                 ]
//             },
//             {
//                 "group": [
//                     {
//                         "length": "0x20",
//                         "location": "memory",
//                         "name": "values-address",
//                         "offset": {
//                             "~sum": [
//                                 "offset",
//                                 "0x20"
//                             ]
//                         }
//                     },
//                     {
//                         "define": {
//                             "offset": {
//                                 "~read": "values-address"
//                             }
//                         },
//                         "in": {
//                             "template": "memory-t_array$_t_uint16_$dyn_storage",
//                             "yields": {
//                                 "item": "values-item",
//                                 "length": "values-length"
//                             }
//                         }
//                     }
//                 ]
//             },
//             {
//                 "group": [
//                     {
//                         "length": "0x20",
//                         "location": "memory",
//                         "name": "text-address",
//                         "offset": {
//                             "~sum": [
//                                 "offset",
//                                 "0x40"
//                             ]
//                         }
//                     },
//                     {
//                         "define": {
//                             "offset": {
//                                 "~read": "text-address"
//                             }
//                         },
//                         "in": {
//                             "template": "memory-t_string_storage",
//                             "yields": {
//                                 "data": "text-data",
//                                 "length": "text-length"
//                             }
//                         }
//                     }
//                 ]
//             },
//             {
//                 "length": "0x04",
//                 "location": "memory",
//                 "name": "tag",
//                 "offset": {
//                     "~sum": [
//                         "offset",
//                         "0x60"
//                     ]
//                 }
//             }
//         ]
//     }
// }
// .resources.pointers.calldata-t_struct$_Record_$22_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "define": {
//                     "offset": "offset"
//                 },
//                 "in": {
//                     "template": "calldata-t_struct$_Point_$11_storage",
//                     "yields": {
//                         "x": "point-x",
//                         "y": "point-y"
//                     }
//                 }
//             },
//             {
//                 "group": [
//                     {
//                         "length": "0x20",
//                         "location": "calldata",
//                         "name": "values-address",
//                         "offset": {
//                             "~sum": [
//                                 "offset",
//                                 "0x40"
//                             ]
//                         }
//                     },
//                     {
//                         "define": {
//                             "offset": {
//                                 "~sum": [
//                                     "offset",
//                                     {
//                                         "~read": "values-address"
//                                     }
//                                 ]
//                             }
//                         },
//                         "in": {
//                             "template": "calldata-t_array$_t_uint16_$dyn_storage",
//                             "yields": {
//                                 "item": "values-item",
//                                 "length": "values-length"
//                             }
//                         }
//                     }
//                 ]
//             },
//             {
//                 "group": [
//                     {
//                         "length": "0x20",
//                         "location": "calldata",
//                         "name": "text-address",
//                         "offset": {
//                             "~sum": [
//                                 "offset",
//                                 "0x60"
//                             ]
//                         }
//                     },
//                     {
//                         "define": {
//                             "offset": {
//                                 "~sum": [
//                                     "offset",
//                                     {
//                                         "~read": "text-address"
//                                     }
//                                 ]
//                             }
//                         },
//                         "in": {
//                             "template": "calldata-t_string_storage",
//                             "yields": {
//                                 "data": "text-data",
//                                 "length": "text-length"
//                             }
//                         }
//                     }
//                 ]
//             },
//             {
//                 "length": "0x04",
//                 "location": "calldata",
//                 "name": "tag",
//                 "offset": {
//                     "~sum": [
//                         "offset",
//                         "0x80"
//                     ]
//                 }
//             }
//         ]
//     }
// }
// .resources.pointers.memory-t_array$_t_array$_t_uint16_$2_storage_$3_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "define": {
//                     "data": "offset"
//                 },
//                 "in": {
//                     "list": {
//                         "count": "0x03",
//                         "each": "index",
//                         "is": {
//                             "group": [
//                                 {
//                                     "length": "0x20",
//                                     "location": "memory",
//                                     "name": "item-address",
//                                     "offset": {
//                                         "~sum": [
//                                             "data",
//                                             {
//                                                 "~product": [
//                                                     "index",
//                                                     "0x20"
//                                                 ]
//                                             }
//                                         ]
//                                     }
//                                 },
//                                 {
//                                     "define": {
//                                         "offset": {
//                                             "~read": "item-address"
//                                         }
//                                     },
//                                     "in": {
//                                         "template": "memory-t_array$_t_uint16_$2_storage",
//                                         "yields": {
//                                             "item": "item-item"
//                                         }
//                                     }
//                                 }
//                             ]
//                         }
//                     }
//                 }
//             }
//         ]
//     }
// }
// .resources.pointers.calldata-t_array$_t_array$_t_uint16_$2_storage_$3_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "define": {
//                     "data": "offset"
//                 },
//                 "in": {
//                     "list": {
//                         "count": "0x03",
//                         "each": "index",
//                         "is": {
//                             "define": {
//                                 "offset": {
//                                     "~sum": [
//                                         "data",
//                                         {
//                                             "~product": [
//                                                 "index",
//                                                 "0x40"
//                                             ]
//                                         }
//                                     ]
//                                 }
//                             },
//                             "in": {
//                                 "template": "calldata-t_array$_t_uint16_$2_storage",
//                                 "yields": {
//                                     "item": "item-item"
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         ]
//     }
// }
// .resources.pointers.memory-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "define": {
//                     "data": "offset"
//                 },
//                 "in": {
//                     "list": {
//                         "count": "0x02",
//                         "each": "index",
//                         "is": {
//                             "group": [
//                                 {
//                                     "length": "0x20",
//                                     "location": "memory",
//                                     "name": "item-address",
//                                     "offset": {
//                                         "~sum": [
//                                             "data",
//                                             {
//                                                 "~product": [
//                                                     "index",
//                                                     "0x20"
//                                                 ]
//                                             }
//                                         ]
//                                     }
//                                 },
//                                 {
//                                     "define": {
//                                         "offset": {
//                                             "~read": "item-address"
//                                         }
//                                     },
//                                     "in": {
//                                         "template": "memory-t_array$_t_bytes_storage_$dyn_storage",
//                                         "yields": {
//                                             "item-address": "item-item-address",
//                                             "item-data": "item-item-data",
//                                             "item-length": "item-item-length",
//                                             "length": "item-length"
//                                         }
//                                     }
//                                 }
//                             ]
//                         }
//                     }
//                 }
//             }
//         ]
//     }
// }
// .resources.pointers.calldata-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "define": {
//                     "data": "offset"
//                 },
//                 "in": {
//                     "list": {
//                         "count": "0x02",
//                         "each": "index",
//                         "is": {
//                             "group": [
//                                 {
//                                     "length": "0x20",
//                                     "location": "calldata",
//                                     "name": "item-address",
//                                     "offset": {
//                                         "~sum": [
//                                             "data",
//                                             {
//                                                 "~product": [
//                                                     "index",
//                                                     "0x20"
//                                                 ]
//                                             }
//                                         ]
//                                     }
//                                 },
//                                 {
//                                     "define": {
//                                         "offset": {
//                                             "~sum": [
//                                                 "data",
//                                                 {
//                                                     "~read": "item-address"
//                                                 }
//                                             ]
//                                         }
//                                     },
//                                     "in": {
//                                         "template": "calldata-t_array$_t_bytes_storage_$dyn_storage",
//                                         "yields": {
//                                             "item-address": "item-item-address",
//                                             "item-data": "item-item-data",
//                                             "item-length": "item-item-length",
//                                             "length": "item-length"
//                                         }
//                                     }
//                                 }
//                             ]
//                         }
//                     }
//                 }
//             }
//         ]
//     }
// }
// .resources.pointers.memory-t_bytes4: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "length": "0x04",
//         "location": "memory",
//         "name": "value",
//         "offset": "offset"
//     }
// }
// .resources.pointers.transient-t_uint16: {
//     "expect": [
//         "slot",
//         "offset"
//     ],
//     "for": {
//         "length": "0x02",
//         "location": "transient",
//         "name": "value",
//         "offset": {
//             "~difference": [
//                 "0x1e",
//                 "offset"
//             ]
//         },
//         "slot": "slot"
//     }
// }
// .resources.pointers | keys: ["calldata-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage","calldata-t_array$_t_array$_t_uint16_$2_storage_$3_storage","calldata-t_array$_t_bytes_storage_$dyn_storage","calldata-t_array$_t_uint16_$2_storage","calldata-t_array$_t_uint16_$dyn_storage","calldata-t_bytes4","calldata-t_bytes_storage","calldata-t_int16","calldata-t_string_storage","calldata-t_struct$_Point_$11_storage","calldata-t_struct$_Record_$22_storage","calldata-t_uint16","calldata-t_uint8","memory-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage","memory-t_array$_t_array$_t_uint16_$2_storage_$3_storage","memory-t_array$_t_bytes_storage_$dyn_storage","memory-t_array$_t_uint16_$2_storage","memory-t_array$_t_uint16_$dyn_storage","memory-t_bytes4","memory-t_bytes_storage","memory-t_int16","memory-t_string_storage","memory-t_struct$_Point_$11_storage","memory-t_struct$_Record_$22_storage","memory-t_uint16","memory-t_uint8","storage-t_array$_t_uint16_$dyn_storage","storage-t_bytes4","storage-t_enum$_Color_$6","storage-t_function_external_nonpayable$__$returns$__$","storage-t_function_internal_nonpayable$__$returns$__$","storage-t_int16","storage-t_string_storage","storage-t_struct$_Point_$11_storage","storage-t_struct$_Record_$22_storage","storage-t_uint16","storage-t_uint8","storage-t_userDefinedValueType$_Price_$3","transient-t_uint16"]
