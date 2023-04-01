// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {DNft} from "../core/DNft.sol";
import {VaultFactory} from "../core/VaultFactory.sol";
import {IVaultsManager} from "../interfaces/IVaultsManager.sol";

contract VaultsManager is IVaultsManager {
  VaultFactory public immutable vaultFactory;
  DNft         public immutable dNft;

  mapping(address => bool)                  public vaults;
  mapping(address => uint)                  public vaultVotes;
  mapping(uint => mapping(address => bool)) public hasVoted;

  uint public constant MIN_VOTES = 200; // will change

  modifier isNftOwner(uint id) {
    if (dNft.ownerOf(id) != msg.sender) revert NotOwner(); _;
  }

  constructor(DNft _dNft, VaultFactory _vaultFactory) {
    dNft         = _dNft;
    vaultFactory = _vaultFactory;
  }

  /// @inheritdoc IVaultsManager
  function voteFor(
      uint id,
      address vault
    ) 
    external 
      isNftOwner(id) 
    {
      if (hasVoted[id][msg.sender]) revert AlreadyVotedFor(); 
      vaultVotes[vault] += 1;
      emit Voted(id, vault, true);
  }

  /// @inheritdoc IVaultsManager
  function voteAgainst(
      uint id,
      address vault
    ) 
    external 
      isNftOwner(id) 
    {
      if (!hasVoted[id][msg.sender]) revert AlreadyVotedAgainst(); 
      vaultVotes[vault] -= 1;
      emit Voted(id, vault, false);
  }

  function addVault(address _vault) external {
    require(vaultFactory.isVault(_vault));
    if (vaultVotes[_vault] < MIN_VOTES) revert TooManyAgainstVotes();
    vaults[_vault] = true;
  }

  function removeVault(address _vault) external {
    require(vaultFactory.isVault(_vault));
    if (vaultVotes[_vault] > MIN_VOTES) revert TooManyForVotes();
    vaults[_vault] = false;
  }
}
