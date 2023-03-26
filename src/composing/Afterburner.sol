// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "../core/DNft.sol";
import {DyadPlus} from "../composing/DyadPlus.sol";
import {IAfterburner} from "../interfaces/IAfterburner.sol";
import {Vault} from "../core/Vault.sol";

contract Afterburner is IAfterburner {
  DNft     dNft;
  DyadPlus dyadPlus;

  mapping(address => bool)                  public vaults;
  mapping(uint => mapping(address => uint)) public deposits;

  constructor(DNft _dNft, DyadPlus _dyadPlus) {
    dNft     = _dNft;
    dyadPlus = _dyadPlus;
  }

  function addVault(address _vault) external {
    vaults[_vault] = true;
  }

  function deposit(uint _tokenId, address _vault, uint _amount) external {
    require(vaults[_vault]);
    Vault(_vault).collat().transferFrom(msg.sender, address(this), _amount);
    deposits[_tokenId][_vault] += _amount;
  }
}
