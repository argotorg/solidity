contract C {
    event TestA(function() external indexed);
    event TestB(function(uint256) external indexed);
    function f1(function() external x) public {
        emit TestA(x);
    }
    function f2(function(uint256) external x) public {
        emit TestB(x);
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f1(function): left(0x347eaa94e3f63220b1f27af5888d33325ddbd4dec27fc3050000000000000000) ->
// ~ emit TestA(function): #0x347eaa94e3f63220b1f27af5888d33325ddbd4dec27fc3050000000000000000
// f2(function): left(0x347eaa94e3f63220b1f27af5888d33325ddbd4debf3724af0000000000000000) ->
// ~ emit TestB(function): #0x347eaa94e3f63220b1f27af5888d33325ddbd4debf3724af0000000000000000
