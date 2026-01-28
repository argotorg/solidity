bytes32 constant blockhGlobal = blockhash(1);
bytes32 constant blobhGlobal = blobhash(1);
uint constant bfGlobal = block.basefee;
uint constant blobbfGlobal = block.blobbasefee;
uint constant chainIdGlobal = block.chainid;
address constant coinbaseGlobal = block.coinbase;
uint constant diffGlobal = block.difficulty;
uint constant gaslimitGlobal = block.gaslimit;
uint constant numberGlobal = block.number;
uint constant prevrandaoGlobal = block.prevrandao;
uint constant timestampGlobal = block.timestamp;
uint constant gGlobal = gasleft();
bytes constant dataGlobal = msg.data;
address constant senderGlobal = msg.sender;
bytes4 constant sigGlobal = msg.sig;
uint constant valueGlobal = msg.value;
uint constant gaspriceGlobal = tx.gasprice;
address constant originGlobal = tx.origin;

contract A {
    bytes32 constant blockh = blockhash(1);
    bytes32 constant blobh = blobhash(1);
    uint constant bf = block.basefee;
    uint constant blobbf = block.blobbasefee;
    uint constant chainId = block.chainid;
    address constant coinbase = block.coinbase;
    uint constant diff = block.difficulty;
    uint constant gaslimit = block.gaslimit;
    uint constant number = block.number;
    uint constant prevrandao = block.prevrandao;
    uint constant timestamp = block.timestamp;
    uint constant g = gasleft();
    bytes constant data = msg.data;
    address constant sender = msg.sender;
    bytes4 constant sig = msg.sig;
    uint constant value = msg.value;
    uint constant gasprice = tx.gasprice;
    address constant origin = tx.origin;
}
// ====
// EVMVersion: >=cancun
// ----
// TypeError 8349: (32-44): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (77-88): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (115-128): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (159-176): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (208-221): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (257-271): Initial value for constant variable has to be compile-time constant.
// Warning 8417: (300-316): Since the VM version paris, "difficulty" was replaced by "prevrandao", which now returns a random number based on the beacon chain.
// TypeError 8349: (300-316): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (349-363): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (394-406): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (441-457): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (491-506): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (532-541): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (571-579): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (613-623): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (653-660): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (690-699): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (732-743): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (777-786): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (832-844): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (875-886): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (911-924): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (953-970): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1000-1013): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1047-1061): Initial value for constant variable has to be compile-time constant.
// Warning 8417: (1088-1104): Since the VM version paris, "difficulty" was replaced by "prevrandao", which now returns a random number based on the beacon chain.
// TypeError 8349: (1088-1104): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1135-1149): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1178-1190): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1223-1239): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1271-1286): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1310-1319): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1347-1355): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1387-1397): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1425-1432): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1460-1469): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1500-1511): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (1543-1552): Initial value for constant variable has to be compile-time constant.
