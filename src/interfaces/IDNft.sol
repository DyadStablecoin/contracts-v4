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
  error IncorrectEthSacrifice();
  error NotLiquidator        ();
  error AlreadySet           ();

  /**
   * @notice Mint a new dNFT to `to`
   * @dev Will revert:
   *      - If the maximum number of public mints has been reached
   *      - If `to` is the zero address
   * @dev Emits:
   *      - MintNft(address indexed to, uint indexed id)
   * @param to The address to mint the dNFT to
   * @return id Id of the new dNFT
   */
  function mintNft(address to) external payable returns (uint id);

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

  /**
   * @notice Add a liquidator
   * @dev Will revert:
   *      - If `msg.sender` is not the factory
   * @param liquidator Address of the liquidator
   */
  function addLiquidator(address liquidator) external;

  /**
   * @notice Transfer dNft with `id` to `to`
   * @dev Will revert:
   *      - If `msg.sender` is not a liquidator
   * @param id Id of the dNFT to transfer
   * @param to Address to send the dNFT to
   */
  function transfer(uint id, address to) external;
}
