struct S { uint256 a; }

function free(S memory s, uint8[] calldata xs) pure returns (bytes memory) {
    return abi.encode(s.a, xs.length);
}

library L {
    function internalFn(int64 v) internal pure returns (int64) { return v; }
    function externalFn(uint256[2] memory) external pure {}
}

contract Base {
    modifier m(address who) { require(who != address(0)); _; }
    function base(bool b) internal pure returns (bool) { return !b; }
}

contract C is Base {
    function f(S calldata s, string memory t) external pure returns (uint32[] memory) {
        return new uint32[](s.a + bytes(t).length);
    }
    function g(address who, S memory s, uint8[] calldata xs) external pure m(who) returns (bytes memory) {
        if (base(L.internalFn(1) > 0))
            return free(s, xs);
        return "";
    }
    // Not called, so not compiled into the contract.
    function unused(int128 v) internal pure returns (int128) { return v; }
}
// ----
// .resources.types | keys: ["t_address","t_array$_t_uint256_$2_storage","t_array$_t_uint32_$dyn_storage","t_array$_t_uint8_$dyn_storage","t_bool","t_bytes_storage","t_int64","t_string_storage","t_struct$_S_$4_storage","t_tuple$_t_address_$","t_tuple$_t_address_$_t_struct$_S_$4_memory_ptr_$_t_array$_t_uint8_$dyn_calldata_ptr_$","t_tuple$_t_array$_t_uint256_$2_memory_ptr_$","t_tuple$_t_array$_t_uint32_$dyn_memory_ptr_$","t_tuple$_t_bool_$","t_tuple$_t_bytes_memory_ptr_$","t_tuple$_t_int64_$","t_tuple$_t_struct$_S_$4_calldata_ptr_$_t_string_memory_ptr_$","t_tuple$_t_struct$_S_$4_memory_ptr_$_t_array$_t_uint8_$dyn_calldata_ptr_$","t_uint256","t_uint32","t_uint8"]
// .resources.pointers | keys: ["calldata-t_array$_t_uint8_$dyn_storage","calldata-t_struct$_S_$4_storage","calldata-t_uint256","calldata-t_uint8","memory-t_array$_t_uint256_$2_storage","memory-t_array$_t_uint32_$dyn_storage","memory-t_bytes_storage","memory-t_string_storage","memory-t_struct$_S_$4_storage","memory-t_uint256","memory-t_uint32"]
