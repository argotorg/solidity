contract C {
    event Test(function() external indexed);
    function f() public {
        emit Test(C(address(0x1234)).f);
    }
}
// ----
// f() ->
// ~ emit Test(function): #0x123426121ff00000000000000000
