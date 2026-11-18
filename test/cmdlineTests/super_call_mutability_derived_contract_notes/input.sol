// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;

contract A {
    function f() public pure virtual returns (uint256) { return 1; }
}

contract X {
    uint256 public s;
    function f() public virtual returns (uint256) { s = 5; return 100; }
}

contract Y {
    function f() public view virtual returns (uint256) { return address(this).balance; }
}

contract B is A {
    function f() public pure virtual override returns (uint256) { return super.f(); }
}

contract D is A, X, B {
    function f() public pure override(A, X, B) returns (uint256) { return super.f(); }
}

contract E is A, Y, B {
    function f() public pure override(A, Y, B) returns (uint256) { return super.f(); }
}
