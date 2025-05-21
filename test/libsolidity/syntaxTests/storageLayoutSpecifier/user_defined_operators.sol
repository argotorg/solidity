type MyUint is uint;

using {add as +} for MyUint global;
function add(MyUint a, MyUint b) pure returns (MyUint) {
    return MyUint.wrap(2);
}

contract C layout at MyUint.wrap(1) + MyUint.wrap(2) {}
// ----
// TypeError 1139: (166-197): The base slot of the storage layout must be a compile-time constant expression.
