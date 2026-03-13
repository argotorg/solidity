// Used to cause ICE in IR codegen when emitting an indexed event parameter
// with an implicitly convertible function type (different state mutability).
contract C {
    event ViewEvent(function() external view indexed);
    event NonpayableEvent(function() external indexed);

    function externalPure() external pure {}
    function externalView() external view {}
    function externalPayable() external payable {}

    // pure -> view
    function test_pure_to_view() public {
        emit ViewEvent(C(address(0x1234)).externalPure);
    }
    // pure -> nonpayable
    function test_pure_to_nonpayable() public {
        emit NonpayableEvent(C(address(0x1234)).externalPure);
    }
    // view -> nonpayable
    function test_view_to_nonpayable() public {
        emit NonpayableEvent(C(address(0x1234)).externalView);
    }
    // payable -> nonpayable
    function test_payable_to_nonpayable() public {
        emit NonpayableEvent(C(address(0x1234)).externalPayable);
    }
}
// ----
// test_pure_to_view() ->
// ~ emit ViewEvent(function): #0x123432de51f20000000000000000
// test_pure_to_nonpayable() ->
// ~ emit NonpayableEvent(function): #0x123432de51f20000000000000000
// test_view_to_nonpayable() ->
// ~ emit NonpayableEvent(function): #0x12347fb3a0c30000000000000000
// test_payable_to_nonpayable() ->
// ~ emit NonpayableEvent(function): #0x12349298fb810000000000000000
