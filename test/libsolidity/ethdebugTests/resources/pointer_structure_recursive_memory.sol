struct Node { uint256 value; Node[] children; }
contract C {
    function f() external pure {
        Node memory node;
        node.children;
    }
}
// ----
// .resources.pointers.memory-t_struct$_Node_$8_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "length": "0x20",
//                 "location": "memory",
//                 "name": "value",
//                 "offset": "offset"
//             },
//             {
//                 "group": [
//                     {
//                         "length": "0x20",
//                         "location": "memory",
//                         "name": "children-address",
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
//                                 "~read": "children-address"
//                             }
//                         },
//                         "in": {
//                             "template": "memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage"
//                         }
//                     }
//                 ]
//             }
//         ]
//     }
// }
// .resources.pointers.memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "group": [
//             {
//                 "length": "0x20",
//                 "location": "memory",
//                 "name": "length",
//                 "offset": "offset"
//             },
//             {
//                 "define": {
//                     "data": {
//                         "~sum": [
//                             "offset",
//                             "0x20"
//                         ]
//                     }
//                 },
//                 "in": {
//                     "list": {
//                         "count": {
//                             "~read": "length"
//                         },
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
//                                         "template": "memory-t_struct$_Node_$8_storage",
//                                         "yields": {
//                                             "children-address": "item-children-address",
//                                             "value": "item-value"
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
// .resources.types | keys: ["t_array$_t_struct$_Node_$8_storage_$dyn_storage","t_struct$_Node_$8_storage","t_tuple$__$","t_uint256"]
// .resources.pointers | keys: ["memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage","memory-t_struct$_Node_$8_storage","memory-t_uint256"]
