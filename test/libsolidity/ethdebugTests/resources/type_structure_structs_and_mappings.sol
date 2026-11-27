struct Point { uint8 x; uint8 y; bytes4 salt; }
struct Line { Point from; Point to; string label; }

contract C {
    Point point;
    Line line;
    // Named and unnamed mappings share type documents.
    mapping(address account => uint256 balance) balances;
    mapping(address owner => mapping(uint256 index => Line line) entries) lines;
    mapping(string => bool) named;
    mapping(address => uint256) unnamedBalances;
}
// ----
// .resources.types | keys: ["t_address","t_bool","t_bytes4","t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$_$","t_mapping$_t_address_$_t_uint256_$","t_mapping$_t_string_memory_ptr_$_t_bool_$","t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$","t_string_storage","t_struct$_Line_$17_storage","t_struct$_Point_$8_storage","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_bool","storage-t_bytes4","storage-t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$_$","storage-t_mapping$_t_address_$_t_uint256_$","storage-t_mapping$_t_string_memory_ptr_$_t_bool_$","storage-t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$","storage-t_string_storage","storage-t_struct$_Line_$17_storage","storage-t_struct$_Point_$8_storage","storage-t_uint256","storage-t_uint8"]
// .resources.types.t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$_$.contains.key.type.id: t_address
// .resources.types.t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$_$.contains.value.type.id: t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$
// .resources.types.t_mapping$_t_address_$_t_uint256_$.contains.key.type.id: t_address
// .resources.types.t_mapping$_t_address_$_t_uint256_$.contains.value.type.id: t_uint256
// .resources.types.t_mapping$_t_address_$_t_uint256_$.contains.key.name: <PATH NOT FOUND>
// .resources.types.t_mapping$_t_address_$_t_uint256_$.contains.value.name: <PATH NOT FOUND>
// .resources.types.t_mapping$_t_string_memory_ptr_$_t_bool_$.contains.key.type.id: t_string_storage
// .resources.types.t_mapping$_t_uint256_$_t_struct$_Line_$17_storage_$.contains.value.type.id: t_struct$_Line_$17_storage
// .resources.types.t_struct$_Line_$17_storage.contains | length: 3
// .resources.types.t_struct$_Line_$17_storage.contains[0].name: from
// .resources.types.t_struct$_Line_$17_storage.contains[0].type.id: t_struct$_Point_$8_storage
// .resources.types.t_struct$_Line_$17_storage.contains[1].name: to
// .resources.types.t_struct$_Line_$17_storage.contains[1].type.id: t_struct$_Point_$8_storage
// .resources.types.t_struct$_Line_$17_storage.contains[2].name: label
// .resources.types.t_struct$_Line_$17_storage.contains[2].type.id: t_string_storage
// .resources.types.t_struct$_Point_$8_storage.contains | length: 3
// .resources.types.t_struct$_Point_$8_storage.contains[0].name: x
// .resources.types.t_struct$_Point_$8_storage.contains[0].type.id: t_uint8
// .resources.types.t_struct$_Point_$8_storage.contains[1].name: y
// .resources.types.t_struct$_Point_$8_storage.contains[1].type.id: t_uint8
// .resources.types.t_struct$_Point_$8_storage.contains[2].name: salt
// .resources.types.t_struct$_Point_$8_storage.contains[2].type.id: t_bytes4
// .resources.types.t_struct$_Line_$17_storage.definition.location.range.offset: 107
// .resources.types.t_struct$_Line_$17_storage.definition.location.range.length: 51
