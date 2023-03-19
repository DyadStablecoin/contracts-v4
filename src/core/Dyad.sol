// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Upgradeable} from "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import {Initializable} from "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";

contract Dyad is Initializable, ERC20Upgradeable {
  address public owner;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor() { _disableInitializers(); }

  function setOwner(address _owner) public onlyOwner {
    owner = _owner;
  }

  function initialize(string memory name, string memory symbol) public virtual initializer {
    __ERC20_init(name, symbol);
    owner = msg.sender;
  }

  function mint(address to,   uint amount) public onlyOwner { _mint(to,   amount); }
  function burn(address from, uint amount) public onlyOwner { _burn(from, amount); }
}
