// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {Owned} from "@solmate/src/auth/Owned.sol";
import {IDNft} from "../interfaces/IDNft.sol";

contract DNft is ERC721Enumerable, Owned, IDNft {
  using SafeTransferLib for address;

  uint public constant INSIDER_MINTS = 300; 
  uint public constant PUBLIC_MINTS  = 1700; 

  uint    public insiderMints; // Number of insider mints
  uint    public publicMints;  // Number of public mints
  address public factory;

  ERC721 public immutable tickets;

  struct Permission {
    bool    hasPermission; 
    uint248 lastUpdated;
  }

  mapping(uint => mapping (address => Permission)) public id2permission; 
  mapping(uint => uint)                            public id2lastOwnershipChange; 

  mapping(uint => bool) public usedTickets; 

  modifier isNftOwner(uint id) {
    if (ownerOf(id) != msg.sender) revert NotOwner(); _;
  }

  constructor(ERC721 _tickets)
      ERC721("Dyad NFT", "dNFT") 
      Owned(msg.sender) 
    {
      tickets = _tickets;
  }

  /// @inheritdoc IDNft
  function mintNft(
    uint    ticket,
    address to
  )
    external 
    returns (uint) {
      if (tickets.ownerOf(ticket) != msg.sender) revert NotTicketOwner();
      if (usedTickets[ticket])                   revert UsedTicket();
      if (++publicMints > PUBLIC_MINTS)          revert PublicMintsExceeded();
      usedTickets[ticket] = true;
      return _mintNft(to);
  }

  /// @inheritdoc IDNft
  function mintInsiderNft(address to)
    external 
      onlyOwner 
    returns (uint) {
      if (++insiderMints > INSIDER_MINTS) revert InsiderMintsExceeded();
      return _mintNft(to); 
  }

  function _mintNft(address to)
    private 
    returns (uint) {
      uint id = totalSupply();
      _safeMint(to, id); // re-entrancy
      emit MintNft(id, to);
      return id;
  }

  /// @inheritdoc IDNft
  function grant(uint id, address operator) 
    external 
      isNftOwner(id) 
    {
      id2permission[id][operator] = Permission(true, uint248(block.number));
      emit Grant(id, operator);
  }

  /// @inheritdoc IDNft
  function revoke(uint id, address operator) 
    external 
      isNftOwner(id) 
    {
      delete id2permission[id][operator];
      emit Revoke(id, operator);
  }

  /// @inheritdoc IDNft
  function hasPermission(uint id, address operator) 
    external 
    view 
    returns (bool) {
      return (
        ownerOf(id) == operator || 
        (
          id2permission[id][operator].hasPermission && 
          id2permission[id][operator].lastUpdated > id2lastOwnershipChange[id]
        )
      );
  }

  /// @inheritdoc IDNft
  function setFactory(address _factory) 
    external 
      onlyOwner 
    {
      if (factory != address(0)) revert AlreadySet();
      factory = _factory;
      emit SetFactory(_factory);
  }

  // We have to set `lastOwnershipChange` in order to reset permissions
  function _beforeTokenTransfer(
      address from,
      address to,
      uint id, 
      uint batchSize 
  ) internal 
    override {
      super._beforeTokenTransfer(from, to, id, batchSize);
      id2lastOwnershipChange[id] = block.number; // resets permissions
  }
}
