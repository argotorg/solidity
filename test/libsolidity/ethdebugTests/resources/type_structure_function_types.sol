contract C {
    function () external externalEmpty;
    function (uint32) external externalNoReturns;
    function () external returns (uint32) externalOneReturn;
    function (uint32) external returns (uint32) externalSingle;
    function (uint32, bool, address) external returns (bytes4, int16) externalMultiple;
    function () internal internalEmpty;
    function (uint32) internal returns (uint32) internalSingle;
    function (uint32, bool, address) internal returns (bytes4, int16) internalMultiple;
}
// ----
// .resources.types | keys: ["t_address","t_bool","t_bytes4","t_function_external_nonpayable$__$returns$__$","t_function_external_nonpayable$__$returns$_t_uint32_$","t_function_external_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$","t_function_external_nonpayable$_t_uint32_$returns$__$","t_function_external_nonpayable$_t_uint32_$returns$_t_uint32_$","t_function_internal_nonpayable$__$returns$__$","t_function_internal_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$","t_function_internal_nonpayable$_t_uint32_$returns$_t_uint32_$","t_int16","t_tuple$__$","t_tuple$_t_bytes4_$_t_int16_$","t_tuple$_t_uint32_$","t_tuple$_t_uint32_$_t_bool_$_t_address_$","t_uint32"]
// .resources.types.t_function_external_nonpayable$__$returns$__$.contains.parameters.type.id: t_tuple$__$
// .resources.types.t_function_external_nonpayable$__$returns$__$.contains.returns: <PATH NOT FOUND>
// .resources.types.t_function_external_nonpayable$_t_uint32_$returns$__$.contains.parameters.type.id: t_tuple$_t_uint32_$
// .resources.types.t_function_external_nonpayable$_t_uint32_$returns$__$.contains.returns: <PATH NOT FOUND>
// .resources.types.t_function_internal_nonpayable$__$returns$__$.contains.parameters.type.id: t_tuple$__$
// .resources.types.t_function_internal_nonpayable$__$returns$__$.contains.returns: <PATH NOT FOUND>
// .resources.types.t_function_external_nonpayable$__$returns$_t_uint32_$.contains.parameters.type.id: t_tuple$__$
// .resources.types.t_function_external_nonpayable$__$returns$_t_uint32_$.contains.returns.type.id: t_tuple$_t_uint32_$
// .resources.types.t_function_external_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$.contains.parameters.type.id: t_tuple$_t_uint32_$_t_bool_$_t_address_$
// .resources.types.t_function_external_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$.contains.returns.type.id: t_tuple$_t_bytes4_$_t_int16_$
// .resources.types.t_function_external_nonpayable$_t_uint32_$returns$_t_uint32_$.contains.parameters.type.id: t_tuple$_t_uint32_$
// .resources.types.t_function_external_nonpayable$_t_uint32_$returns$_t_uint32_$.contains.returns.type.id: t_tuple$_t_uint32_$
// .resources.types.t_function_internal_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$.contains.parameters.type.id: t_tuple$_t_uint32_$_t_bool_$_t_address_$
// .resources.types.t_function_internal_nonpayable$_t_uint32_$_t_bool_$_t_address_$returns$_t_bytes4_$_t_int16_$.contains.returns.type.id: t_tuple$_t_bytes4_$_t_int16_$
// .resources.types.t_function_internal_nonpayable$_t_uint32_$returns$_t_uint32_$.contains.parameters.type.id: t_tuple$_t_uint32_$
// .resources.types.t_function_internal_nonpayable$_t_uint32_$returns$_t_uint32_$.contains.returns.type.id: t_tuple$_t_uint32_$
// .resources.types.t_function_external_nonpayable$__$returns$__$.definition: <PATH NOT FOUND>
// .resources.types.t_function_internal_nonpayable$__$returns$__$.definition: <PATH NOT FOUND>
// .resources.types.t_tuple$__$.contains | length: 0
// .resources.types.t_tuple$_t_bytes4_$_t_int16_$.contains | length: 2
// .resources.types.t_tuple$_t_bytes4_$_t_int16_$.contains[0].type.id: t_bytes4
// .resources.types.t_tuple$_t_bytes4_$_t_int16_$.contains[1].type.id: t_int16
// .resources.types.t_tuple$_t_uint32_$.contains | length: 1
// .resources.types.t_tuple$_t_uint32_$.contains[0].type.id: t_uint32
// .resources.types.t_tuple$_t_uint32_$_t_bool_$_t_address_$.contains | length: 3
// .resources.types.t_tuple$_t_uint32_$_t_bool_$_t_address_$.contains[0].type.id: t_uint32
// .resources.types.t_tuple$_t_uint32_$_t_bool_$_t_address_$.contains[1].type.id: t_bool
// .resources.types.t_tuple$_t_uint32_$_t_bool_$_t_address_$.contains[2].type.id: t_address
