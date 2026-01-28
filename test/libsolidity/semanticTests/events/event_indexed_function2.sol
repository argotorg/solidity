contract C {
    event TestA(function() external indexed);
    event TestB(function(uint256) external indexed);
    function f1() public {
        emit TestA(C(address(0x1234)).f1);
    }
    function f2(uint256 a) public {
        emit TestB(C(address(0x1234)).f2);
    }
}
// ----
// f1() ->
// ~ emit TestA(function): #0x1234c27fc3050000000000000000
// f2(uint256): 1 ->
// ~ emit TestB(function): #0x1234bf3724af0000000000000000
