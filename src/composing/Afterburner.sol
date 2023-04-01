// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "../core/DNft.sol";
import {DyadPlus} from "../composing/DyadPlus.sol";
import {IAfterburner} from "../interfaces/IAfterburner.sol";
import {Vault} from "../core/Vault.sol";
import {VaultsManager} from "./VaultsManager.sol";
import {VaultFactory} from "../core/VaultFactory.sol";

contract Afterburner is IAfterburner, VaultsManager {
  DyadPlus public immutable dyadPlus;

  // dNFT id => (vault => deposited dyad)
  mapping(uint => mapping(address => uint)) public depositedDyad;
  // dNFT id => (vault => burned dyad)
  mapping(uint => mapping(address => uint)) public burnedDyad;

  constructor(
    DNft         _dNft,
    DyadPlus     _dyadPlus, 
    VaultFactory _vaultFactory
  ) VaultsManager(_dNft, _vaultFactory) {
    dyadPlus     = _dyadPlus;
  }

  /// @inheritdoc IAfterburner
  function deposit(
      uint    tokenId,
      address vault,
      uint    amount
  ) external 
      isNftOwner(tokenId) 
    {
      require(vaults[vault]);
      Vault(vault).collat().transferFrom(msg.sender, address(this), amount);
      depositedDyad[tokenId][vault] += amount;
  }

  function withdraw(
      uint    tokenId,
      address vault,
      uint    amount,
      address recipient
  ) external 
      isNftOwner(tokenId) 
    {
      require(vaults[vault]);
      depositedDyad[tokenId][vault] -= amount;
      Vault(vault).collat().transfer(recipient, amount);
  }

  /// @inheritdoc IAfterburner
  function mint(
      uint    tokenId,
      address vault,
      uint    amount, 
      address recipient
  ) external 
      isNftOwner(tokenId) 
    {
      require(vaults[vault]);
      Vault(vault).dyad().transferFrom(msg.sender, address(this), amount);
      dyadPlus.mint(recipient, amount);
      burnedDyad[tokenId][vault] += amount;
      emit Minted(tokenId, vault, amount, recipient);
  }

  /// @inheritdoc IAfterburner
  function redeem(
      uint    tokenId,
      address vault,
      uint    amount, 
      address recipient
  ) external 
      isNftOwner(tokenId) 
    {
      require(vaults[vault]);
      dyadPlus.transferFrom(recipient, address(this), amount);
      dyadPlus.burn(address(this), amount);
      burnedDyad[tokenId][vault] -= amount;
      emit Redeemed(tokenId, vault, amount, recipient);
  }
}
