==== Source: constants.sol ====
uint8 constant USED = 1;
uint16 constant UNUSED = 2;
int24 constant DEPENDENCY = 3;
uint32 constant DERIVED = uint32(uint24(DEPENDENCY));
bytes constant DATA = hex"ab";
string constant TEXT = "text";
==== Source: consumer.sol ====
import {USED as ALIAS} from "constants.sol";

contract C {
    function f() external pure { ALIAS; }
}
// ----
// .resources.types | keys: ["t_bytes_storage","t_int24","t_string_storage","t_tuple$__$","t_uint16","t_uint32","t_uint8"]
// .resources.pointers | keys: []
