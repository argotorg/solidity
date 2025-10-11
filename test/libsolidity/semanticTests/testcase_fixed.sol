pragma solidity =0.8.30;

contract C {
    function f1(address[] calldata funcs) internal {
        funcs[0];
    }

    function f2() external {
        address(this);
    }
}
