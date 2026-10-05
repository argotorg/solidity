struct Point { uint8 x; uint8 y; }

contract C {
    uint256 counter;
    Point origin;
    mapping(address => uint256) balances;
    uint256 transient temporary;
    uint256 immutable created = 1;
    uint256 constant LIMIT = 2;

    function f() public view returns (uint256) {
        return created + LIMIT;
    }
}
// ====
// EVMVersion: >=cancun
// ----
// C.semantic.scopes | keys: ["34"]
// C.semantic.scopes.34.0.variableDefinitions | length: 4
// C.semantic.scopes.34.0.variableDefinitions[0].identifier: counter
// C.semantic.scopes.34.0.variableDefinitions[0].pointer: {"location":"storage","slot":"0x00"}
// C.semantic.scopes.34.0.variableDefinitions[1].identifier: origin
// C.semantic.scopes.34.0.variableDefinitions[1].pointer: {
//     "define": {
//         "slot": "0x01"
//     },
//     "in": {
//         "template": "storage-t_struct$_Point_$6_storage"
//     }
// }
// C.semantic.scopes.34.0.variableDefinitions[2].identifier: balances
// C.semantic.scopes.34.0.variableDefinitions[2].pointer: {"location":"storage","slot":"0x02"}
// C.semantic.scopes.34.0.variableDefinitions[3].identifier: temporary
// C.semantic.scopes.34.0.variableDefinitions[3].pointer: {"location":"transient","slot":"0x00"}
// C.semantic.resources.pointers | keys: ["storage-t_mapping$_t_address_$_t_uint256_$","storage-t_struct$_Point_$6_storage","storage-t_uint256","storage-t_uint8","transient-t_uint256"]
