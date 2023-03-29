// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "../core/DNft.sol";
import {DyadPlus} from "../composing/DyadPlus.sol";
import {IAfterburner} from "../interfaces/IAfterburner.sol";
import {Vault} from "../core/Vault.sol";
import {VaultFactory} from "../core/VaultFactory.sol";

contract Afterburner is IAfterburner {
  DNft         dNft;
  VaultFactory vaultFactory;
  DyadPlus     dyadPlus;

  mapping(address => bool)                  public vaults;
  mapping(uint => mapping(address => uint)) public deposits;
  mapping(address => uint)                  public vaultVotes;

  constructor(
    DNft         _dNft,
    VaultFactory _vaultFactory,
    DyadPlus     _dyadPlus
  ) {
    dNft         = _dNft;
    vaultFactory = _vaultFactory;
    dyadPlus     = _dyadPlus;
  }

  // onboard new collateral type
  function addVault(address _vault) external {
    require(vaultFactory.isVault(_vault));
    vaults[_vault] = true;
  }

  function voteFor(address vault) external {
    vaultVotes[vault] += 1;
  }

  function voteAgainst(address vault) external {
    vaultVotes[vault] -= 1;
  }

  function deposit(
      uint    tokenId,
      address vault,
      uint    amount
  ) external {
      require(vaults[vault]);
      Vault(vault).collat().transferFrom(msg.sender, address(this), amount);
      deposits[tokenId][vault] += amount;
  }

  function withdraw(
      uint    tokenId,
      address vault,
      uint    amount,
      address recipient
  ) external {
      require(vaults[vault]);
      require(deposits[tokenId][vault] >= amount);
      deposits[tokenId][vault] -= amount;
      Vault(vault).collat().transfer(recipient, amount);
  }

  function mint(
      address recipient,
      uint    amount
  ) external {
      dyadPlus.mint(recipient, amount);
  }
}
