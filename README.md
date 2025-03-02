// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { AccessControlDefaultAdminRules } from
  "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";
import { PixelDungeonsItems } from "./PixelDungeonsItems.sol";

contract PixelDungeonsRewards is AccessControlDefaultAdminRules, ReentrancyGuard, ERC721Holder, ERC1155Holder {
  using BitMaps for BitMaps.BitMap;
  using SafeERC20 for IERC20;

  bytes32 public constant SENDER_ROLE = keccak256("SENDER_ROLE");
  bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

  enum Category {
    ETHER,
    ITEM,
    ERC20,
    ERC721,
    ERC1155
  }

  struct Item {
    Category category;
    address receiver;
    uint256 amount;
    uint256 tokenId; // Used for Item, ERC721, ERC1155 rewards
    address tokenAddress; // Used for ERC20, ERC721, ERC1155 rewards
  }

  struct Reward {
    uint256 topic; // game, tournament, referral, etc.
    uint256 id;
    Item[] items;
  }

  address payable public recipient;
  PixelDungeonsItems public immutable items;
  mapping(uint256 => BitMaps.BitMap) private sentRewards;

  event RewardSent(uint256 indexed topic, uint256 indexed id);

  error InvalidRecipient(address recipient);

  constructor(PixelDungeonsItems _items, address _recipient) AccessControlDefaultAdminRules(2 days, msg.sender) {
    items = _items;
    recipient = payable(_recipient);
  }

  function hasSentReward(uint256 _topic, uint256 _id) public view returns (bool) {
    return sentRewards[_topic].get(_id);
  }

  function setRecipient(address payable _recipient) public onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_recipient == address(0)) {
      revert InvalidRecipient(_recipient);
    }

    recipient = _recipient;
  }

  function sendRewards(Reward[] calldata _rewards) external virtual onlyRole(SENDER_ROLE) nonReentrant {
    for (uint256 i = 0; i < _rewards.length; i++) {
      Reward calldata reward = _rewards[i];

      if (!hasSentReward(reward.topic, reward.id)) {
        for (uint256 j = 0; j < reward.items.length; j++) {
          Item calldata item = reward.items[j];

          if (item.category == Category.ETHER) {
            Address.sendValue(payable(item.receiver), item.amount);
          } else if (item.category == Category.ITEM) {
            items.mint(item.receiver, item.tokenId, item.amount, "");
          } else if (item.category == Category.ERC20) {
            IERC20(item.tokenAddress).safeTransfer(item.receiver, item.amount);
          } else if (item.category == Category.ERC721) {
            IERC721(item.tokenAddress).safeTransferFrom(address(this), item.receiver, item.tokenId);
          } else if (item.category == Category.ERC1155) {
            IERC1155(item.tokenAddress).safeTransferFrom(address(this), item.receiver, item.tokenId, item.amount, "");
          }
        }

        _markRewardAsSent(reward.topic, reward.id);
      }
    }
  }

  function _markRewardAsSent(uint256 _topic, uint256 _id) internal {
    sentRewards[_topic].set(_id);
    emit RewardSent(_topic, _id);
  }

  function withdrawEther(uint256 _amount) external onlyRole(WITHDRAW_ROLE) {
    Address.sendValue(recipient, _amount);
  }

  function withdrawERC20(IERC20 _token, uint256 _amount) external onlyRole(WITHDRAW_ROLE) {
    _token.safeTransfer(recipient, _amount);
  }

  function withdrawERC721(IERC721 _token, uint256 _tokenId) external onlyRole(WITHDRAW_ROLE) {
    _token.safeTransferFrom(address(this), recipient, _tokenId);
  }

  function withdrawERC1155(IERC1155 _token, uint256 _id, uint256 _amount) external onlyRole(WITHDRAW_ROLE) {
    _token.safeTransferFrom(address(this), recipient, _id, _amount, "");
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC1155Holder, AccessControlDefaultAdminRules)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  receive() external payable { }
}
# The Solidity Contract-Oriented Programming Language

[![Matrix Chat](https://img.shields.io/badge/Matrix%20-chat-brightgreen?style=plastic&logo=matrix)](https://matrix.to/#/#ethereum_solidity:gitter.im)
[![Gitter Chat](https://img.shields.io/badge/Gitter%20-chat-brightgreen?style=plastic&logo=gitter)](https://gitter.im/ethereum/solidity)
[![Solidity Forum](https://img.shields.io/badge/Solidity_Forum%20-discuss-brightgreen?style=plastic&logo=discourse)](https://forum.soliditylang.org/)
[![X Follow](https://img.shields.io/twitter/follow/solidity_lang?style=plastic&logo=x)](https://X.com/solidity_lang)
[![Mastodon Follow](https://img.shields.io/mastodon/follow/000335908?domain=https%3A%2F%2Ffosstodon.org%2F&logo=mastodon&style=plastic)](https://fosstodon.org/@solidity)

You can talk to us on Gitter and Matrix, tweet at us on X (previously Twitter) or create a new topic in the Solidity forum. Questions, feedback, and suggestions are welcome!

Solidity is a statically-typed, contract-oriented, high-level language for implementing smart contracts on the Ethereum platform.

For a good overview and starting point, please check out the official [Solidity Language Portal](https://soliditylang.org).

## Table of Contents

- [Background](#background)
- [Build and Install](#build-and-install)
- [Example](#example)
- [Documentation](#documentation)
- [Development](#development)
- [Maintainers](#maintainers)
- [License](#license)
- [Security](#security)

## Background

Solidity is a statically-typed curly-braces programming language designed for developing smart contracts
that run on the Ethereum Virtual Machine. Smart contracts are programs that are executed inside a peer-to-peer
network where nobody has special authority over the execution, and thus they allow anyone to implement tokens of value,
ownership, voting, and other kinds of logic.

When deploying contracts, you should use the latest released version of
Solidity. This is because breaking changes, as well as new features and bug fixes, are
introduced regularly. We currently use a 0.x version
number [to indicate this fast pace of change](https://semver.org/#spec-item-4).

## Build and Install

Instructions about how to build and install the Solidity compiler can be
found in the [Solidity documentation](https://docs.soliditylang.org/en/latest/installing-solidity.html#building-from-source).


## Example

A "Hello World" program in Solidity is of even less use than in other languages, but still:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract HelloWorld {
    function helloWorld() external pure returns (string memory) {
        return "Hello, World!";
    }
}
```

To get started with Solidity, you can use [Remix](https://remix.ethereum.org/), which is a
browser-based IDE. Here are some example contracts:

1. [Voting](https://docs.soliditylang.org/en/latest/solidity-by-example.html#voting)
2. [Blind Auction](https://docs.soliditylang.org/en/latest/solidity-by-example.html#blind-auction)
3. [Safe remote purchase](https://docs.soliditylang.org/en/latest/solidity-by-example.html#safe-remote-purchase)
4. [Micropayment Channel](https://docs.soliditylang.org/en/latest/solidity-by-example.html#micropayment-channel)

## Documentation

The Solidity documentation is hosted using [Read the Docs](https://docs.soliditylang.org).

## Development

Solidity is still under development. Contributions are always welcome!
Please follow the
[Developer's Guide](https://docs.soliditylang.org/en/latest/contributing.html)
if you want to help.

You can find our current feature and bug priorities for forthcoming
releases in the [projects section](https://github.com/ethereum/solidity/projects).

## Maintainers
The Solidity programming language and compiler are open-source community projects governed by a core team.
The core team is sponsored by the [Ethereum Foundation](https://ethereum.foundation/).

## License
Solidity is licensed under [GNU General Public License v3.0](LICENSE.txt).

Some third-party code has its [own licensing terms](cmake/templates/license.h.in).

## Security

The security policy may be [found here](SECURITY.md).
