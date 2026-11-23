contract C {
    function one() internal pure returns (uint) { return 1; }
    function two() internal pure returns (uint) { return 2; }
    function three() internal pure returns (uint) { return 3; }

    function() internal pure returns (uint)[] source;
    function() internal pure returns (uint)[] target;

    constructor() {
        source = [one, two, three];
        target = new function() internal pure returns (uint)[](3);
    }

    function test() external returns (uint, uint, uint) {
        target = source;
        assert(target.length == 3);
        return (target[0](), target[1](), target[2]());
    }
}
// ----
// test() -> 1, 2, 3
