// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

interface IVault {
  error StaleData            ();
  error IncompleteRound      ();
  error CrTooLow             ();
  error CrTooHigh            ();
  error InvalidNft           ();
  error NotOwner             ();
  error MissingPermission    ();
  error InvalidCollateral();

  event Deposit  (uint indexed id, uint amount);
  event Redeem   (uint indexed from, uint amount, address indexed to, uint collat);
  event Liquidate(uint indexed id, address indexed to);
  event Withdraw (uint indexed from, address indexed to, uint amount);
  event MintDyad (uint indexed from, address indexed to, uint amount);
  event BurnDyad (uint indexed id, uint amount);

  /**
   * @notice Deposit collateral 
   * @dev Will revert:
   *      - If new deposit equals zero shares
   *      - If dNFT with id `id` does not exist
   * @dev Emits:
   *      - Deposit(uint indexed id, uint amount)
   * @dev For Auditors:
   *      - To save gas it does not check if `msg.value` is zero 
   * @param id Id of the dNFT that gets the deposited DYAD
   * @param id Amount of collateral to deposit
   */
  function deposit(uint id, uint amount) external;

  /**
   * @notice Withdraw collateral from dNFT
   * @dev Will revert:
   *      - If `msg.sender` is not the owner of the dNFT AND does not have 
   *        permission
   *      - If `amount` to withdraw is larger than the dNFT deposit
   *      - If Collateralization Ratio is is less than the min collaterization 
   *        ratio after the withdrawal
   * @dev Emits:
   *      - Withdraw(uint indexed from, address indexed to, uint amount)
   * @dev For Auditors:
   *      - To save gas it does not check if `amount` is 0 
   *      - To save gas it only fails implicitly if `from` does not have enough
   *        deposited collateral
   * @param from Id of the dNFT to withdraw from
   * @param to Address to send the collateral to
   * @param amount Amount of collateral to withdraw
   * @return Amount of collateral withdrawn
   */
  function withdraw(uint from, address to, uint amount) external returns (uint);

  /**
   * @notice Mint `amount` of DYAD as an ERC-20 token from dNFT
   * @dev Will revert:
   *      - If `msg.sender` is not the owner of the dNFT AND does not have 
   *        permission
   *      - If amount is larger than the dNFT collateral deposit
   *      - If Collateralization Ratio is is less than the min collaterization 
   *        ratio after the mint
   * @dev Emits:
   *      - MintDyad(uint indexed from, address indexed to, uint amount)
   * @dev For Auditors:
   *      - To save gas it does not check if `amount` is 0 
   * @param from Id of the dNFT to mint from
   * @param to Address to send the DYAD to
   * @param amount Amount of DYAD to mint
   */
  function mintDyad(uint from, address to, uint amount) external;

  /**
   * @notice Burn `amount` of DYAD 
   * @dev Will revert:
   *      - If dNFT with id `id` does not exist
   *      - If DYAD balance of dNFT is smaller than `amount`
   * @dev Emits:
   *      - BurnDyad(uint indexed from, address indexed to, uint amount)
   * @dev For Auditors:
   *      - To save gas it does not check if `amount` is 0 
   * @param id Id of the dNFT to mint from
   * @param amount Amount of DYAD to mint
   */
  function burnDyad(uint id, uint amount) external;

  /**
   * @notice Redeem DYAD ERC20 for collateral
   * @dev Will revert:
   *      - If DYAD to redeem is larger thatn `msg.sender` DYAD balance
   *      - If amount exceeds the dNFT DYAD balance
   *      - If amount of collateral exceeds the dNFT collateral balance
   *      - If the collateral transfer fails
   * @dev Emits:
   *      - Redeem(uint indexed from, address indexed to, uint amount)
   * @dev For Auditors:
   *      - To save gas it does not check if `amount` is 0 
   *      - `dyad.burn` is called in the beginning so we can revert as fast as
   *        possible if `msg.sender` does not have enough DYAD. The dyad contract
   *        is trusted so it introduces no re-entrancy risk. The revert is implicit
   *        and happens in the _burn function of the ERC20 contract as an underflow.
   *      - There is a re-entrancy risk while transfering the collateral, that is why the 
   *        `all state changes are done before the collateral transfer. I do not see why
   *        a `nonReentrant` modifier would be needed here, lets save the gas.
   * @param from dNFT to redeem from
   * @param to Address to send the collateral to
   * @param amount Amount of DYAD to redeem
   * @return collateral Amount of collateral redeemed for DYAD
   */
  function redeem(uint from, address to, uint amount) external returns (uint);

  /**
   * @notice Liquidate dNFT by covering its missing deposit and transfering it 
   *         to a new owner
   * @dev Will revert:
   *      - If dNFT is over the `LIQUIDATION_THRESHLD` after deposit
   *      - If collateral sent is not enough to put it over the `LIQUIDATION_THRESHLD`
   * @dev Emits:
   *      - Liquidate(address indexed to, uint indexed id)
   * @dev For Auditors:
   *      - No need to check if the dNFT exists because a dNFT `transfer` will
   *        revert if it does not exist.
   *      - Permissions for this dNFT are reset because `_transfer` calls 
   *        `_beforeTokenTransfer`, where we set `lastOwnershipChange`
   * @param id Id of the dNFT to liquidate
   * @param to Address to send the dNFT to
   */
  function liquidate(uint id, address to, uint amount) external;

  // /**
  //  * @notice Grant permission to an `operator`
  //  * @notice Minting a DNft and grant it some permissions in the same block is
  //  *         not possible, because it could be exploited by regular transfers.
  //  * @dev Will revert:
  //  *      - If `msg.sender` is not the owner of the dNFT  
  //  * @dev Emits:
  //  *      - Grant(uint indexed id, address indexed operator)
  //  * @param id Id of the dNFT's permissions to modify
  //  * @param operator Operator to grant/revoke permissions for
  //  */
  // function grant(uint id, address operator) external;

  // /**
  //  * @notice Revoke permission from an `operator`
  //  * @notice Minting a DNft and revoking the permission in the same block is
  //  *         not possible, because it could be exploited by regular transfers.
  //  * @dev Will revert:
  //  *      - If `msg.sender` is not the owner of the dNFT  
  //  * @dev Emits:
  //  *      - Revoke(uint indexed id, address indexed operator)
  //  * @param id Id of the dNFT's permissions to modify
  //  * @param operator Operator to revoke permissions from
  //  */
  // function revoke(uint id, address operator) external;
}
