// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {FixedPointMathLib} from "@solmate/src/utils/FixedPointMathLib.sol";

import {IVault} from "../interfaces/IVault.sol";
import {IAggregatorV3} from "../interfaces/AggregatorV3Interface.sol";
import {Dyad} from "./Dyad.sol";
import {DNft} from "./DNft.sol";

contract Vault is IVault {
  using SafeERC20         for ERC20;
  using SafeCast          for int;
  using FixedPointMathLib for uint;

  uint public constant MIN_COLLATERIZATION_RATIO = 3e18; // 300%

  mapping(uint => uint) public id2collat; // nft id => collateral
  mapping(uint => uint) public id2dyad;   // nft id => dyad 

  DNft          public dNft;
  Dyad          public dyad;
  ERC20         public collat;
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

  constructor(
      address       _dNft, 
      address       _collat,       // collateral
      string memory _collatSymbol, 
      address       _collatOracle  // collat/USD chainlink oracle
  ) {
      dNft   = DNft(_dNft);
      collat = ERC20(_collat); 
      oracle = IAggregatorV3(_collatOracle);

      dyad = new Dyad(
        string.concat(_collatSymbol, "DYAD-"),
        string.concat("d", _collatSymbol), 
        address(this)
      );
  }

  /// @inheritdoc IVault
  function deposit(uint id, uint amount) 
    public 
      isValidNft(id) 
    {
      collat.safeTransferFrom(msg.sender, address(this), amount);
      id2collat[id] += amount;
      emit Deposit(id, amount);
  }

  /// @inheritdoc IVault
  function withdraw(uint from, address to, uint amount) 
    public 
      isNftOwnerOrHasPermission(from) 
    returns (uint) {
      id2collat[from] -= amount;
      if (_collatRatio(from) < MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
      collat.safeTransfer(to, amount);
      emit Withdraw(from, to, amount);
      return amount;
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
    external {
      dyad.burn(msg.sender, amount);
      id2dyad[id] -= amount;
      emit BurnDyad(id, amount);
  }

  /// @inheritdoc IVault
  function liquidate(uint id, address to, uint amount) 
    external {
      if (_collatRatio(id) >= MIN_COLLATERIZATION_RATIO) revert CrTooHigh(); 
      deposit(id, amount);
      if (_collatRatio(id) <  MIN_COLLATERIZATION_RATIO) revert CrTooLow(); 
      emit Liquidate(id, to);
  }

  /// @inheritdoc IVault
  function redeem(uint from, address to, uint amount)
    external 
      isNftOwnerOrHasPermission(from)
    returns (uint) { 
      dyad.burn(msg.sender, amount);
      id2dyad[from]    -= amount;
      uint _collat      = amount * (10**oracle.decimals()) / _collatPrice();
      withdraw(from, to, _collat);
      emit Redeem(from, amount, to, _collat);
      return _collat;
  }

  // collateralization ratio of the dNFT
  function _collatRatio(uint id) 
    private 
    view 
    returns (uint) {
      uint _dyad = id2dyad[id]; // save gas
      if (_dyad == 0) return type(uint).max;
      uint _collat = id2collat[id] * _collatPrice() / (10**oracle.decimals());
      return _collat.divWadDown(_dyad);
  }

  // collateral price in USD
  function _collatPrice() 
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
