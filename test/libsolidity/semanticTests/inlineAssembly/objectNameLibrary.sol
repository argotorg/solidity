library Lib {
    struct S {
        uint v;
    }
    function add(uint a, uint b) external pure returns(uint ret) {
        ret = a + b;
    }
}

interface ILib {
    function add(uint a, uint b) external pure returns (uint);
}

contract C {
    address addr;

    function create_lib() public {
        address l;
        assembly {
            l := eofcreate(Lib.objectName, 0, 0, 0, 0)

        }
        addr = l;
    }

    function add() public returns(uint){
        return ILib(addr).add(5, 7);
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// create_lib()
// add() -> 12
