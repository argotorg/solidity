type Price is uint128;
enum Color { Red, Green, Blue }
interface I { function f() external; }
library L { function id(uint256 a) internal pure returns (uint256) { return a; } }

contract C {
    Color color;
    Price price;
    I other;
    C self;
    function (uint256) internal pure returns (uint256) internalFunction;
    function (uint256) external returns (bool) externalFunction;
    function g(uint256 a) public pure returns (uint256) { return L.id(a); }
}
// Calling L.id adds its parameter and return types, but not a type for L.
// Library names cannot be used as variable types.
// ----
// .resources.types | keys: ["t_bool","t_contract$_C_$64","t_contract$_I_$11","t_enum$_Color_$7","t_function_external_nonpayable$_t_uint256_$returns$_t_bool_$","t_function_internal_pure$_t_uint256_$returns$_t_uint256_$","t_tuple$__$","t_tuple$_t_bool_$","t_tuple$_t_uint256_$","t_uint128","t_uint256","t_userDefinedValueType$_Price_$3"]
// .resources.pointers | keys: ["storage-t_contract$_C_$64","storage-t_contract$_I_$11","storage-t_enum$_Color_$7","storage-t_function_external_nonpayable$_t_uint256_$returns$_t_bool_$","storage-t_function_internal_pure$_t_uint256_$returns$_t_uint256_$","storage-t_userDefinedValueType$_Price_$3"]
// .resources.types.t_contract$_C_$64.definition.name: C
// .resources.types.t_contract$_C_$64.interface: <PATH NOT FOUND>
// .resources.types.t_contract$_C_$64.payable: false
// .resources.types.t_contract$_I_$11.definition.name: I
// .resources.types.t_contract$_I_$11.interface: true
// .resources.types.t_enum$_Color_$7.values: ["Red","Green","Blue"]
// .resources.types.t_enum$_Color_$7.definition.location.range.offset: 82
// .resources.types.t_enum$_Color_$7.definition.location.range.length: 31
// .resources.types.t_function_external_nonpayable$_t_uint256_$returns$_t_bool_$.external: true
// .resources.types.t_function_external_nonpayable$_t_uint256_$returns$_t_bool_$.contains.parameters.type.id: t_tuple$_t_uint256_$
// .resources.types.t_function_external_nonpayable$_t_uint256_$returns$_t_bool_$.contains.returns.type.id: t_tuple$_t_bool_$
// .resources.types.t_function_internal_pure$_t_uint256_$returns$_t_uint256_$.internal: true
// .resources.types.t_function_internal_pure$_t_uint256_$returns$_t_uint256_$.contains.parameters.type.id: t_tuple$_t_uint256_$
// .resources.types.t_function_internal_pure$_t_uint256_$returns$_t_uint256_$.contains.returns.type.id: t_tuple$_t_uint256_$
// .resources.types.t_userDefinedValueType$_Price_$3.kind: alias
// .resources.types.t_userDefinedValueType$_Price_$3.contains.type.id: t_uint128
// .resources.types.t_userDefinedValueType$_Price_$3.definition.name: Price
