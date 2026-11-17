// Only Created's uint24 constructor parameter and the callable-list tuples should appear.
// The other declarations and expression-only type uses must not add types.
struct Unused { uint8 member; }
enum E { A, B }
type T is uint16;

function extension(uint32 value) pure returns (uint32) { return value; }

contract Created {
    constructor(uint24) {}
}

contract C {
    struct Inner { uint40 member; }
    event Event(uint48);
    error Failure(uint56);
    using {extension} for uint32;

    function f() external {
        emit Event(1);
        if (false) revert Failure(1);
        uint64(1);
        uint72;
        T.wrap(1);
        E(1);
        Created(address(1));
        new Created(1);
        new uint80[](1);
        Unused(1);
        Inner(1);
        abi.decode(hex"", (uint88));
        bytes.concat(hex"01", hex"02");
    }
}
// ----
// .resources.types | keys: ["t_tuple$__$","t_tuple$_t_uint24_$","t_uint24"]
// .resources.pointers | keys: []
