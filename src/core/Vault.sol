// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {SafeTransferLib} from "@solmate/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";
import {Owned} from "@solmate/src/auth/Owned.sol";

import {IVault} from "../interfaces/IVault.sol";
import {IAggregatorV3} from "../interfaces/AggregatorV3Interface.sol";
import {Dyad} from "./Dyad.sol";
import {DNft} from "./DNft.sol";

contract Vault is Initializable, IVault {
  using SafeTransferLib   for address;
  using SafeCast          for int;
  using FixedPointMathLib for uint;

  uint public constant MIN_COLLATERIZATION_RATIO = 3e18; // 300%

  mapping(uint => uint) public id2collat; // nft id => collateral
  mapping(uint => uint) public id2dyad;   // nft id => dyad 

  DNft          public dNft;
  Dyad          public dyad;
  IERC20        public collateral;
  IAggregatorV3 public oracle;

  modifier isValidNft(uint id) {
    if (id >= dNft.totalSupply()) revert InvalidNft(); _;
  }
  modifier isNftOwner(uint id) {
    if (dNft.ownerOf(id) != msg.sender) revert NotOwner(); _;
  }
  modifier isNftOwnerOrHasPermission(uint id) {
    if (!dNft.hasPermission(id, msg.sender)) revert MissingPermission() ; _;
  }

  constructor() { _disableInitializers(); }

  function initialize(
      address _dNft, 
      address _dyad,
      address _collateral,
      address _oracle 
  ) 
    external 
      initializer 
  {
      dNft       = DNft(_dNft);
      dyad       = Dyad(_dyad);
      collateral = IERC20(_collateral);
      oracle     = IAggregatorV3(_oracle);
  }

  /// @inheritdoc IVault
  function deposit(uint id, uint amount) 
    external 
      isValidNft(id) 
  {
    collateral.transferFrom(msg.sender, address(this), amount);
    id2collat[id] += amount;
    emit Deposit(id, amount);
  }

  /// @inheritdoc IVault
  function withdraw(uint from, address to, uint amount) 
    external 
      isNftOwnerOrHasPermission(from) 
    {
      id2collat[from] -= amount;
      if (_collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
      collateral.transfer(to, amount);
      emit Withdraw(from, to, amount);
  }

  /// @inheritdoc IVault
  function mintDyad(uint from, address to, uint amount)
    external 
      isNftOwnerOrHasPermission(from)
    {
      id2dyad[from] += amount;
      if (_collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
      dyad.mint(to, amount);
      emit MintDyad(from, to, amount);
  }

  /// @inheritdoc IVault
  function burnDyad(uint id, uint amount) 
    external 
  {
    dyad.burn(msg.sender, amount);
    id2dyad[id] -= amount;
    emit BurnDyad(id, amount);
  }

  /// @inheritdoc IVault
  function liquidate(uint id, address to, uint amount) 
    external {
      if (_collatRatio(id) >= MIN_COLLATERIZATION_RATIO) revert CrTooHigh(); 
      id2collat[id] += amount;
      if (_collatRatio(id) <  MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
      dNft.liquidate(id, to);
      emit Liquidate(id, to);
  }

  /// @inheritdoc IVault
  function redeem(uint from, address to, uint amount)
    external 
      isNftOwnerOrHasPermission(from)
    returns (uint) { 
      dyad.burn(msg.sender, amount);
      id2dyad[from] -= amount;
      uint collat    = amount * (10**oracle.decimals()) / _getEthPrice();
      id2collat[from]  -= collat;
      collateral.transfer(to, amount);
      emit Redeem(from, amount, to, collat);
      return collat;
  }

  // Get Collateralization Ratio of the dNFT
  function _collatRatio(uint id) 
    private 
    view 
    returns (uint) {
      uint _dyad = id2dyad[id]; // save gas
      if (_dyad == 0) return type(uint).max;
      // cr = deposit / withdrawn
      return (id2collat[id] * _getEthPrice() / (10**oracle.decimals())).divWadDown(_dyad);
  }

  // collateral price in USD
  function _getEthPrice() 
    private 
    view 
    returns (uint) {
      (
        uint80 roundID,
        int256 price,
        , 
        uint256 timeStamp, 
        uint80 answeredInRound
      ) = oracle.latestRoundData();
      if (timeStamp == 0)            revert IncompleteRound();
      if (answeredInRound < roundID) revert StaleData();
      return price.toUint256();
  }
}
