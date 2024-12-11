contract C {
    event TestA(function() external indexed);
    event TestB(function(uint256) external indexed);
    function f1() public {
        emit TestA(this.f1);
    }
    function f2(uint256 a) public {
        emit TestB(this.f2);
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f1() ->
// ~ emit TestA(function): #0x347eaa94e3f63220b1f27af5888d33325ddbd4dec27fc3050000000000000000
// f2(uint256): 1 ->
// ~ emit TestB(function): #0x347eaa94e3f63220b1f27af5888d33325ddbd4debf3724af0000000000000000
