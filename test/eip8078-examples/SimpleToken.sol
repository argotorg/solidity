// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleToken
 * @notice Example ERC20-like token with subscribable Transfer events
 * @dev Demonstrates EIP-8078 with multi-parameter events
 */
contract SimpleToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Subscribable Transfer event with multiple indexed parameters
    event subscribable Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    ) gasHint(100000);

    // Subscribable Approval event
    event subscribable Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    ) gasHint(50000);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(to != address(0), "Cannot transfer to zero address");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        require(to != address(0), "Cannot transfer to zero address");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }
}
