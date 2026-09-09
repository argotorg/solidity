type $Amount is uint128;
enum $Choice { First, Second }
struct $Record { uint256 $member; $Amount $amount; $Choice $choice; }

contract $C {
    uint256 $value;
    $Record $struct;
    $Record[] $items;
    $C $self;
}
// ----
// .resources.types | keys: ["t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage","t_contract$_$$$C_$28","t_enum$_$$$Choice_$6","t_struct$_$$$Record_$15_storage","t_uint128","t_uint256","t_userDefinedValueType$_$$$Amount_$3"]
// .resources.types.t_contract$_$$$C_$28.definition.name: $C
// .resources.types.t_enum$_$$$Choice_$6.definition.name: $Choice
// .resources.types.t_struct$_$$$Record_$15_storage.definition.name: $Record
// .resources.types.t_userDefinedValueType$_$$$Amount_$3.definition.name: $Amount
// .resources.pointers | keys: ["storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage","storage-t_contract$_$$$C_$28","storage-t_enum$_$$$Choice_$6","storage-t_struct$_$$$Record_$15_storage","storage-t_uint256","storage-t_userDefinedValueType$_$$$Amount_$3"]
// .resources.pointers: {
//     "storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage": {
//         "expect": [
//             "slot"
//         ],
//         "for": {
//             "group": [
//                 {
//                     "location": "storage",
//                     "name": "length",
//                     "slot": "slot"
//                 },
//                 {
//                     "define": {
//                         "data": {
//                             "~keccak256": [
//                                 {
//                                     "~wordsized": "slot"
//                                 }
//                             ]
//                         }
//                     },
//                     "in": {
//                         "list": {
//                             "count": {
//                                 "~read": "length"
//                             },
//                             "each": "index",
//                             "is": {
//                                 "define": {
//                                     "slot": {
//                                         "~sum": [
//                                             "data",
//                                             {
//                                                 "~product": [
//                                                     "index",
//                                                     "0x02"
//                                                 ]
//                                             }
//                                         ]
//                                     }
//                                 },
//                                 "in": {
//                                     "template": "storage-t_struct$_$$$Record_$15_storage",
//                                     "yields": {
//                                         "$amount": "item-$amount",
//                                         "$choice": "item-$choice",
//                                         "$member": "item-$member"
//                                     }
//                                 }
//                             }
//                         }
//                     }
//                 }
//             ]
//         }
//     },
//     "storage-t_contract$_$$$C_$28": {
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
//     "storage-t_enum$_$$$Choice_$6": {
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
//     "storage-t_struct$_$$$Record_$15_storage": {
//         "expect": [
//             "slot"
//         ],
//         "for": {
//             "group": [
//                 {
//                     "location": "storage",
//                     "name": "$member",
//                     "slot": "slot"
//                 },
//                 {
//                     "length": "0x10",
//                     "location": "storage",
//                     "name": "$amount",
//                     "offset": "0x10",
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "0x01"
//                         ]
//                     }
//                 },
//                 {
//                     "length": "0x01",
//                     "location": "storage",
//                     "name": "$choice",
//                     "offset": "0x0f",
//                     "slot": {
//                         "~sum": [
//                             "slot",
//                             "0x01"
//                         ]
//                     }
//                 }
//             ]
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
//     "storage-t_userDefinedValueType$_$$$Amount_$3": {
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
//     }
// }
