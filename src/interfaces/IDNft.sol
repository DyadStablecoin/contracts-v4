// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

interface IDNft {
  event MintNft      (uint indexed id, address indexed to);
  event Grant        (uint indexed id, address indexed operator);
  event Revoke       (uint indexed id, address indexed operator);
  event SetFactory   (address indexed factory);
  event AddLiquidator(address indexed liquidator);

  error NotOwner             ();
  error NotFactory           ();
  error PublicMintsExceeded  ();
  error InsiderMintsExceeded ();
  error NotLiquidator        ();
  error AlreadySet           ();
  error UsedTicket           ();
  error NotTicketOwner       ();

  /**
   * @dev Mints an dNFT and transfers it to the given `to` address.
   * 
   * Requirements:
   * - The sender must be the owner of the `ticket` being used to mint the NFT.
   * - The `ticket` must not have been used to mint an NFT before.
   * - The number of public mints must not exceed the maximum limit defined by `PUBLIC_MINTS`.
   *
   * Emits a {NFTMinted} event on successful execution.
   *
   * @param ticket The ticket ID to be used for minting the NFT.
   * @param to The address to which the minted NFT will be transferred.
   * @return id The ID of the minted NFT.
   *
   * Throws a {NotTicketOwner} error if the sender is not the owner of the ticket.
   * Throws a {UsedTicket} error if the ticket has already been used to mint an NFT.
   * Throws a {PublicMintsExceeded} error if the number of public mints has already reached the defined limit.
   */
  function mintNft(uint ticket, address to) external returns (uint id);

  /**
   * @notice Mint new insider DNft to `to` 
   * @dev Note:
   *      - An insider dNFT does not require buring ETH to mint
   * @dev Will revert:
   *      - If not called by contract owner
   *      - If the maximum number of insider mints has been reached
   *      - If `to` is the zero address
   * @dev Emits:
   *      - MintNft(address indexed to, uint indexed id)
   * @param to The address to mint the dNFT to
   * @return id Id of the new dNFT
   */
  function mintInsiderNft(address to) external returns (uint id);

  /**
   * @notice Grant permission to an `operator`
   * @notice Minting a DNft and grant it some permissions in the same block is
   *         not possible, because it could be exploited by regular transfers.
   * @dev Will revert:
   *      - If `msg.sender` is not the owner of the dNFT  
   * @dev Emits:
   *      - Grant(uint indexed id, address indexed operator)
   * @param id Id of the dNFT's permissions to modify
   * @param operator Operator to grant/revoke permissions for
   */
  function grant(uint id, address operator) external;

  /**
   * @notice Revoke permission from an `operator`
   * @notice Minting a DNft and revoking the permission in the same block is
   *         not possible, because it could be exploited by regular transfers.
   * @dev Will revert:
   *      - If `msg.sender` is not the owner of the dNFT  
   * @dev Emits:
   *      - Revoke(uint indexed id, address indexed operator)
   * @param id Id of the dNFT's permissions to modify
   * @param operator Operator to revoke permissions from
   */
  function revoke(uint id, address operator) external;

  /**
   * @notice Check if `operator` has permission for dNft with `id`
   * @param id       Id of the dNFT's permissions to check
   * @param operator Operator to check permissions for
   * @return True if `operator` has permission to act on behalf of `id`
   */
  function hasPermission(uint id, address operator) external view returns (bool);

  /**
   * @notice Set the factory address
   * @dev Will revert:
   *      - If `msg.sender` is not the owner of the dNFT contract
   *      - If factory was already set before
   * @param factory Address of the factory
   */
  function setFactory(address factory) external;
}
