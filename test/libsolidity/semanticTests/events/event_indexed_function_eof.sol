contract C {
    event Test(function() external indexed);
    function f() public {
        emit Test(this.f);
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f() ->
// ~ emit Test(function): #0x8f8cc95dcbe7358c1cf1409d3a7ad079e89576bb26121ff00000000000000000
