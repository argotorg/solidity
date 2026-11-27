contract C {
    function (uint32, bool) external returns (address, int16) callback;
    constructor(uint8, bool) {}
    modifier m(uint80) { _; }
    function empty() external pure {}
    function one(uint64 value) external pure m(value) returns (bool) { return false; }
    function multiple(uint32, bool) external pure returns (address, int16) { return (address(0), 0); }
    function unused(uint200) internal pure returns (uint208) { return 0; }
}
// ----
// .resources.types | keys: ["t_address","t_bool","t_function_external_nonpayable$_t_uint32_$_t_bool_$returns$_t_address_$_t_int16_$","t_int16","t_tuple$__$","t_tuple$_t_address_$_t_int16_$","t_tuple$_t_bool_$","t_tuple$_t_uint32_$_t_bool_$","t_tuple$_t_uint64_$","t_tuple$_t_uint80_$","t_tuple$_t_uint8_$_t_bool_$","t_uint32","t_uint64","t_uint8","t_uint80"]
// .resources.types.t_function_external_nonpayable$_t_uint32_$_t_bool_$returns$_t_address_$_t_int16_$.contains.parameters.type.id: t_tuple$_t_uint32_$_t_bool_$
// .resources.types.t_function_external_nonpayable$_t_uint32_$_t_bool_$returns$_t_address_$_t_int16_$.contains.returns.type.id: t_tuple$_t_address_$_t_int16_$
// .resources.types.t_tuple$__$.contains | length: 0
// .resources.types.t_tuple$_t_address_$_t_int16_$.contains | length: 2
// .resources.types.t_tuple$_t_address_$_t_int16_$.contains[0].type.id: t_address
// .resources.types.t_tuple$_t_address_$_t_int16_$.contains[1].type.id: t_int16
// .resources.types.t_tuple$_t_uint32_$_t_bool_$.contains | length: 2
// .resources.types.t_tuple$_t_uint32_$_t_bool_$.contains[0].type.id: t_uint32
// .resources.types.t_tuple$_t_uint32_$_t_bool_$.contains[1].type.id: t_bool
// .resources.types.t_tuple$_t_bool_$.contains[0].type.id: t_bool
// .resources.types.t_tuple$_t_uint64_$.contains[0].type.id: t_uint64
// .resources.types.t_tuple$_t_uint80_$.contains[0].type.id: t_uint80
// .resources.types.t_tuple$_t_uint8_$_t_bool_$.contains | length: 2
// .resources.types.t_tuple$_t_uint8_$_t_bool_$.contains[0].type.id: t_uint8
// .resources.types.t_tuple$_t_uint8_$_t_bool_$.contains[1].type.id: t_bool
