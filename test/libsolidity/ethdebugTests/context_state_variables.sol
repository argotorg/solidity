struct Point { uint8 x; uint8 y; }

contract C {
    uint256 counter;
    mapping(address => uint256) balances;
    uint8 packed;
    bool flag;
    Point origin;
    uint256 transient temporary;
    uint256 constant CONSTANT = 1;
    function f(uint256 argument) public { counter += argument; }
}
// ====
// EVMVersion: >=cancun
// ----
// C.creation.context.variables | length: 6
// C.creation.context.variables[0].identifier: counter
// C.creation.context.variables[0].declaration.source.id: 0
// C.creation.context.variables[0].type: {"id":"t_uint256"}
// C.creation.context.variables[0].pointer: {"location":"storage","slot":"0x00"}
// C.creation.context.variables[1].identifier: balances
// C.creation.context.variables[1].type: {"id":"t_mapping$_t_address_$_t_uint256_$"}
// C.creation.context.variables[1].pointer: {"location":"storage","slot":"0x01"}
// C.creation.context.variables[2].identifier: packed
// C.creation.context.variables[2].pointer: {"length":"0x01","location":"storage","offset":"0x1f","slot":"0x02"}
// C.creation.context.variables[3].identifier: flag
// C.creation.context.variables[3].pointer: {"length":"0x01","location":"storage","offset":"0x1e","slot":"0x02"}
// C.creation.context.variables[4].identifier: origin
// C.creation.context.variables[4].type: {"id":"t_struct$_Point_$6_storage"}
// C.creation.context.variables[4].pointer: {
//     "define": {
//         "slot": "0x03"
//     },
//     "in": {
//         "template": "storage-t_struct$_Point_$6_storage"
//     }
// }
// C.creation.context.variables[5].identifier: temporary
// C.creation.context.variables[5].pointer: {"location":"transient","slot":"0x00"}
// C.runtime.context.variables | length: 6
// C.runtime.context.variables[0].identifier: counter
// C.runtime.context.variables[4].pointer: {
//     "define": {
//         "slot": "0x03"
//     },
//     "in": {
//         "template": "storage-t_struct$_Point_$6_storage"
//     }
// }
// C.runtime.context.variables[5].identifier: temporary
