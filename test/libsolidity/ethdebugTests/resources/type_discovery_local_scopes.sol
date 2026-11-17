interface I {
    function value() external returns (uint8);
    function callback(uint16) external returns (uint24);
}

struct Local {
    uint32 member;
    uint40[] items;
}

contract C {
    function f() external {
        Local memory local = Local(1, new uint40[](1));
        function (uint16) external returns (uint24) callback = I(address(1)).callback;
        callback;
        try I(address(1)).value() returns (uint8 success) {
            uint48 successLocal = success;
        } catch Error(string memory reason) {
            uint56 errorLocal = uint56(bytes(reason).length);
        } catch Panic(uint256 code) {
            uint64 panicLocal = uint64(code);
        } catch (bytes memory data) {
            uint72 catchLocal = uint72(data.length);
        }
    }
}
// ----
// .resources.types | keys: ["t_array$_t_uint40_$dyn_storage","t_bytes_storage","t_function_external_nonpayable$_t_uint16_$returns$_t_uint24_$","t_string_storage","t_struct$_Local_$20_storage","t_tuple$__$","t_tuple$_t_uint16_$","t_tuple$_t_uint24_$","t_tuple$_t_uint8_$","t_uint16","t_uint24","t_uint256","t_uint32","t_uint40","t_uint48","t_uint56","t_uint64","t_uint72","t_uint8"]
// .resources.pointers | keys: ["memory-t_array$_t_uint40_$dyn_storage","memory-t_bytes_storage","memory-t_string_storage","memory-t_struct$_Local_$20_storage","memory-t_uint32","memory-t_uint40"]
