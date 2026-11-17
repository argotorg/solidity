struct Packed {
    uint8 a;
    uint16 b;
    bool c;
    address d;
    uint256 e;
    bytes32 f;
    uint128 g;
    uint128 h;
    uint64 i;
}

contract C {
    Packed packed;
}
// ----
// .resources.types | keys: ["t_address","t_bool","t_bytes32","t_struct$_Packed_$20_storage","t_uint128","t_uint16","t_uint256","t_uint64","t_uint8"]
// .resources.pointers | keys: ["storage-t_address","storage-t_bool","storage-t_bytes32","storage-t_struct$_Packed_$20_storage","storage-t_uint128","storage-t_uint16","storage-t_uint256","storage-t_uint64","storage-t_uint8"]
// .resources.pointers: {
//     "storage-t_address": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x14",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x0c",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     },
//     "storage-t_bool": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x01",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x1f",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     },
//     "storage-t_bytes32": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x20",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x00",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     },
//     "storage-t_struct$_Packed_$20_storage": {
//         "expect": [
//             "slot"
//         ],
//         "for": {
//             "group": [
//                 {
//                     "length": "0x01",
//                     "location": "storage",
//                     "name": "a",
//                     "offset": "0x1f",
//                     "slot": "slot"
//                 },
//                 {
//                     "length": "0x02",
//                     "location": "storage",
//                     "name": "b",
//                     "offset": "0x1d",
//                     "slot": "slot"
//                 },
//                 {
//                     "length": "0x01",
//                     "location": "storage",
//                     "name": "c",
//                     "offset": "0x1c",
//                     "slot": "slot"
//                 },
//                 {
//                     "length": "0x14",
//                     "location": "storage",
//                     "name": "d",
//                     "offset": "0x08",
//                     "slot": "slot"
//                 },
//                 {
//                     "location": "storage",
//                     "name": "e",
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "0x01"
//                         ]
//                     }
//                 },
//                 {
//                     "location": "storage",
//                     "name": "f",
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "0x02"
//                         ]
//                     }
//                 },
//                 {
//                     "length": "0x10",
//                     "location": "storage",
//                     "name": "g",
//                     "offset": "0x10",
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "0x03"
//                         ]
//                     }
//                 },
//                 {
//                     "length": "0x10",
//                     "location": "storage",
//                     "name": "h",
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "0x03"
//                         ]
//                     }
//                 },
//                 {
//                     "length": "0x08",
//                     "location": "storage",
//                     "name": "i",
//                     "offset": "0x18",
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "0x04"
//                         ]
//                     }
//                 }
//             ]
//         }
//     },
//     "storage-t_uint128": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x10",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x10",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     },
//     "storage-t_uint16": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x02",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x1e",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     },
//     "storage-t_uint256": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x20",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x00",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     },
//     "storage-t_uint64": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x08",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x18",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     },
//     "storage-t_uint8": {
//         "expect": [
//             "slot",
//             "offset"
//         ],
//         "for": {
//             "length": "0x01",
//             "location": "storage",
//             "name": "value",
//             "offset": {
//                 "~difference": [
//                     "0x1f",
//                     "offset"
//                 ]
//             },
//             "slot": "slot"
//         }
//     }
// }
