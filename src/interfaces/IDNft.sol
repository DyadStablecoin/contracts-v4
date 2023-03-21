// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

interface IDNft {
  event MintNft(uint indexed id, address indexed to);
  event Grant  (uint indexed id, address indexed operator);
  event Revoke (uint indexed id, address indexed operator);

  error NotOwner             ();
  error NotFactory           ();
  error PublicMintsExceeded  ();
  error InsiderMintsExceeded ();
  error IncorrectEthSacrifice();
  error NotLiquidator        ();
  error AlreadySet           ();

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
   * @notice Check if an `operator` has permission for DNft with `id`
   * @param id       Id of the dNFT's permissions to check
   * @param operator Operator to check permissions for
   * @return True if `operator` has permission to act on behalf of `id`
   */
  function hasPermission(uint id, address operator) external view returns (bool);
}
