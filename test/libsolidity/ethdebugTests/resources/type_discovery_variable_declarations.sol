uint8 constant FILE_CONSTANT = 1;

contract Base {
    uint16 constant BASE_CONSTANT = 2;
    uint24 immutable baseImmutable = 3;
    uint32 stored;
}

contract C is Base {
    uint40 constant PRIVATE_CONSTANT = 4;
    uint48 public constant PUBLIC_CONSTANT = 5;
    uint56 immutable privateImmutable = 6;
    uint64 public immutable publicImmutable = 7;
    uint72 transient temporary;
    bytes constant DATA = hex"ab";
    string constant TEXT = "text";

    constructor(uint80 parameter) {
        uint88 constructorLocal = uint88(parameter);
    }

    modifier m(uint96 parameter) {
        uint104 modifierLocal = uint104(parameter);
        _;
    }

    function f(uint112 parameter) public m(1) returns (uint120 result) {
        uint128 local = uint128(parameter);
        { uint136 nested = uint136(local); }
        for (uint144 i; i < 1; ++i) {}
        (uint152 first, , uint160 last) = (1, 2, 3);
        uint168[] memory values = new uint168[](1);
        result = uint120(first + last + values.length);
    }

    // unused() is never referenced, so uint176 and uint184 must stay out of the type table.
    function unused(uint176 parameter) internal pure {
        uint184 unusedLocal = uint184(parameter);
    }
}
// ====
// EVMVersion: >=cancun
// ----
// .resources.types | keys: ["t_array$_t_uint168_$dyn_storage","t_bytes_storage","t_string_storage","t_tuple$_t_uint112_$","t_tuple$_t_uint120_$","t_tuple$_t_uint80_$","t_tuple$_t_uint96_$","t_uint104","t_uint112","t_uint120","t_uint128","t_uint136","t_uint144","t_uint152","t_uint16","t_uint160","t_uint168","t_uint24","t_uint32","t_uint40","t_uint48","t_uint56","t_uint64","t_uint72","t_uint8","t_uint80","t_uint88","t_uint96"]
// .resources.pointers | keys: ["memory-t_array$_t_uint168_$dyn_storage","memory-t_uint168","storage-t_uint32","transient-t_uint72"]
