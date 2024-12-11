contract C {
    event Test(function() external indexed);
    function f(function() external x) public {
        emit Test(x);
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f(function): left(0x8f8cc95dcbe7358c1cf1409d3a7ad079e89576bb26121ff00000000000000000) ->
// ~ emit Test(function): #0x8f8cc95dcbe7358c1cf1409d3a7ad079e89576bb26121ff00000000000000000
