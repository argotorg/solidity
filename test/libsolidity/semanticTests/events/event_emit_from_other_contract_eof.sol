contract D {
    event Deposit(address indexed _from, bytes32 indexed _id, uint _value);
    function deposit(bytes32 _id) public payable {
        emit Deposit(msg.sender, _id, msg.value);
    }
}
contract C {
    D d;
    constructor() {
        d = new D();
    }
    function deposit(bytes32 _id) public payable {
        d.deposit(_id);
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// constructor() ->
// gas irOptimized: 113970
// gas irOptimized code: 51400
// gas legacy: 119776
// gas legacy code: 125000
// gas legacyOptimized: 114187
// gas legacyOptimized code: 57400
// deposit(bytes32), 18 wei: 0x1234 ->
// ~ emit Deposit(address,bytes32,uint256) from 0x178b67010aadf7caa75a5b294c151a60000863f3: #0x3950196ad64ce098024d887b715727413ca56a14, #0x1234, 0x00
