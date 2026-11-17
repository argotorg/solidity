uint8 constant FILE_VALUE = 1;
bytes constant FILE_BYTES = hex"ab";

abstract contract A {
    uint16 constant VALUE = 1;
    uint24 immutable immutableValue;
    function scalar(uint32 parameter) external virtual returns (bytes32);
    function arrays(uint40[] calldata input) external virtual returns (uint48[] memory);
}

interface I {
    function arrays(uint56[] calldata input) external returns (uint64[] memory);
}
// ----
// .resources.types | keys: ["t_array$_t_uint40_$dyn_storage","t_array$_t_uint48_$dyn_storage","t_array$_t_uint56_$dyn_storage","t_array$_t_uint64_$dyn_storage","t_bytes32","t_bytes_storage","t_tuple$_t_array$_t_uint40_$dyn_calldata_ptr_$","t_tuple$_t_array$_t_uint48_$dyn_memory_ptr_$","t_tuple$_t_array$_t_uint56_$dyn_calldata_ptr_$","t_tuple$_t_array$_t_uint64_$dyn_memory_ptr_$","t_tuple$_t_bytes32_$","t_tuple$_t_uint32_$","t_uint16","t_uint24","t_uint32","t_uint40","t_uint48","t_uint56","t_uint64","t_uint8"]
// .resources.pointers: {}
