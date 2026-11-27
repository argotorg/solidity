struct Point { uint8 x; uint8 y; }

contract C {
    // Named and unnamed mappings share type documents and pointer templates.
    mapping(address account => uint256 balance) balances;
    mapping(address account => mapping(uint256 id => bool enabled) permissions) nested;
    mapping(string => uint256) byName;
    mapping(bytes => uint256) byBytes;
    mapping(uint256 => Point) points;
    mapping(uint256 => uint256[]) lists;
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => uint8))) deep;
    mapping(address => uint256) unnamedBalances;
}
// ----
// .resources.types | keys: ["t_address","t_array$_t_uint256_$dyn_storage","t_bool","t_bytes32","t_bytes_storage","t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_bool_$_$","t_mapping$_t_address_$_t_uint256_$","t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$_$","t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$","t_mapping$_t_bytes32_$_t_uint8_$","t_mapping$_t_bytes_memory_ptr_$_t_uint256_$","t_mapping$_t_string_memory_ptr_$_t_uint256_$","t_mapping$_t_uint256_$_t_array$_t_uint256_$dyn_storage_$","t_mapping$_t_uint256_$_t_bool_$","t_mapping$_t_uint256_$_t_struct$_Point_$6_storage_$","t_string_storage","t_struct$_Point_$6_storage","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_array$_t_uint256_$dyn_storage","storage-t_bool","storage-t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_bool_$_$","storage-t_mapping$_t_address_$_t_uint256_$","storage-t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$_$","storage-t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$","storage-t_mapping$_t_bytes32_$_t_uint8_$","storage-t_mapping$_t_bytes_memory_ptr_$_t_uint256_$","storage-t_mapping$_t_string_memory_ptr_$_t_uint256_$","storage-t_mapping$_t_uint256_$_t_array$_t_uint256_$dyn_storage_$","storage-t_mapping$_t_uint256_$_t_bool_$","storage-t_mapping$_t_uint256_$_t_struct$_Point_$6_storage_$","storage-t_struct$_Point_$6_storage","storage-t_uint256","storage-t_uint8"]
// .resources.pointers.storage-t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_bool_$_$.for.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_bool_$_$.for.length: <PATH NOT FOUND>
// .resources.pointers.storage-t_mapping$_t_address_$_t_uint256_$.for.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$_$.for.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$_$.for.length: <PATH NOT FOUND>
// .resources.pointers.storage-t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$.for.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_bytes32_$_t_mapping$_t_bytes32_$_t_uint8_$_$.for.length: <PATH NOT FOUND>
// .resources.pointers.storage-t_mapping$_t_bytes32_$_t_uint8_$.for.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_bytes32_$_t_uint8_$.for.offset: 0x1f
// .resources.pointers.storage-t_mapping$_t_bytes32_$_t_uint8_$.for.length: 0x01
// .resources.pointers.storage-t_mapping$_t_bytes_memory_ptr_$_t_uint256_$.for.slot: {"~keccak256":["key",{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_string_memory_ptr_$_t_uint256_$.for.slot: {"~keccak256":["key",{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_array$_t_uint256_$dyn_storage_$.for.define.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_array$_t_uint256_$dyn_storage_$.for.in.template: storage-t_array$_t_uint256_$dyn_storage
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_array$_t_uint256_$dyn_storage_$.for.in.yields.item: value-item
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_array$_t_uint256_$dyn_storage_$.for.in.yields.length: value-length
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_bool_$.for.offset: 0x1f
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_bool_$.for.length: 0x01
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_bool_$.for.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_struct$_Point_$6_storage_$.for.define.slot: {"~keccak256":[{"~wordsized":"key"},{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_struct$_Point_$6_storage_$.for.in.template: storage-t_struct$_Point_$6_storage
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_struct$_Point_$6_storage_$.for.in.yields.x: value-x
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_struct$_Point_$6_storage_$.for.in.yields.y: value-y
