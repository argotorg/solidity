uint200 constant FILE_VALUE = 1;
bytes constant FILE_BYTES = hex"ab";

struct MemoryOnly { uint40 member; function (uint96) external callback; }
struct CalldataOnly { uint48 member; function (uint104) external returns (uint112) callback; }
struct StorageOnly { uint56 member; }

contract C {
    uint8 stored;
    uint16 transient temporary;
    uint24 constant CONSTANT = 1;
    uint32 immutable immutableValue = 1;
    StorageOnly storedStruct;

    function inspect(uint64 parameter, MemoryOnly memory input, CalldataOnly calldata data)
        external pure returns (uint72 result)
    {
        uint80 local = uint80(parameter);
        result = uint72(local + input.member + data.member);
    }
}
// ====
// EVMVersion: >=cancun
// ----
// .resources.types | keys: ["t_bytes_storage","t_function_external_nonpayable$_t_uint104_$returns$_t_uint112_$","t_function_external_nonpayable$_t_uint96_$returns$__$","t_struct$_CalldataOnly_$27_storage","t_struct$_MemoryOnly_$16_storage","t_struct$_StorageOnly_$30_storage","t_tuple$_t_uint104_$","t_tuple$_t_uint112_$","t_tuple$_t_uint64_$_t_struct$_MemoryOnly_$16_memory_ptr_$_t_struct$_CalldataOnly_$27_calldata_ptr_$","t_tuple$_t_uint72_$","t_tuple$_t_uint96_$","t_uint104","t_uint112","t_uint16","t_uint200","t_uint24","t_uint32","t_uint40","t_uint48","t_uint56","t_uint64","t_uint72","t_uint8","t_uint80","t_uint96"]
// .resources.pointers | keys: ["calldata-t_function_external_nonpayable$_t_uint104_$returns$_t_uint112_$","calldata-t_struct$_CalldataOnly_$27_storage","calldata-t_uint48","memory-t_function_external_nonpayable$_t_uint96_$returns$__$","memory-t_struct$_MemoryOnly_$16_storage","memory-t_uint40","storage-t_struct$_StorageOnly_$30_storage","storage-t_uint56","storage-t_uint8","transient-t_uint16"]
// .resources.pointers.memory-t_function_external_nonpayable$_t_uint96_$returns$__$: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "length": "0x18",
//         "location": "memory",
//         "name": "value",
//         "offset": "offset"
//     }
// }
// .resources.pointers.calldata-t_function_external_nonpayable$_t_uint104_$returns$_t_uint112_$: {
//     "expect": [
//         "offset"
//     ],
//     "for": {
//         "length": "0x18",
//         "location": "calldata",
//         "name": "value",
//         "offset": "offset"
//     }
// }
