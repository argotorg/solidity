struct $ { uint8 $; uint8 _$_; }
struct _$_ { $ a; $ b; }

contract C {
    $ first;
    _$_ second;
}
// ----
// .resources.types | keys: ["t_struct$_$$$_$6_storage","t_struct$__$$$__$13_storage","t_uint8"]
// .resources.types.t_struct$_$$$_$6_storage.definition.name: $
// .resources.types.t_struct$__$$$__$13_storage.definition.name: _$_
// .resources.pointers: {
//     "storage-t_struct$_$$$_$6_storage": {
//         "expect": [
//             "slot"
//         ],
//         "for": {
//             "group": [
//                 {
//                     "length": "0x01",
//                     "location": "storage",
//                     "name": "$",
//                     "offset": "0x1f",
//                     "slot": "slot"
//                 },
//                 {
//                     "length": "0x01",
//                     "location": "storage",
//                     "name": "_$_",
//                     "offset": "0x1e",
//                     "slot": "slot"
//                 }
//             ]
//         }
//     },
//     "storage-t_struct$__$$$__$13_storage": {
//         "expect": [
//             "slot"
//         ],
//         "for": {
//             "group": [
//                 {
//                     "template": "storage-t_struct$_$$$_$6_storage",
//                     "yields": {
//                         "$": "a-$",
//                         "_$_": "a-_$_"
//                     }
//                 },
//                 {
//                     "define": {
//                         "slot": {
//                             "~sum": [
//                                 "slot",
//                                 "0x01"
//                             ]
//                         }
//                     },
//                     "in": {
//                         "template": "storage-t_struct$_$$$_$6_storage",
//                         "yields": {
//                             "$": "b-$",
//                             "_$_": "b-_$_"
//                         }
//                     }
//                 }
//             ]
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
