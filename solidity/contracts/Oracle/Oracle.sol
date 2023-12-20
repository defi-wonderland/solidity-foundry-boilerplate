pragma solidity ^0.8.19;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IWrapper} from '../../interfaces/Oracle/IWrapper.sol';
import {IOracle} from '../../interfaces/Oracle/IOracle.sol';

contract Oracle is Ownable, IOracle {
  mapping(address _tokenA => mapping(address _tokenB => IWrapper _wrapper)) public pairWrappers;
  mapping(address _tokenA => IWrapper _wrapper) public tokenWrappers;
  IWrapper public defaultWrapper;
  mapping(string _wrapperName => IWrapper _wrapper) public wrapperRegistry;

  modifier checkWrapper(string memory _wrapperName) {
    if (address(wrapperRegistry[_wrapperName]) == address(0)) revert WrapperNotRegistered();
    _;
  }

  constructor() Ownable(msg.sender) {}

  function registerWrapper(string memory _wrapperName, IWrapper _wrapper) public onlyOwner {
    wrapperRegistry[_wrapperName] = _wrapper;

    emit WrapperRegistered(_wrapperName, _wrapper);
  }

  /// @dev Sets wrapper for a given pair, if the pair is quoted then this price is returned first
  /// @dev Order of tokens doesn't matter
  /// @param _tokenA First token in the pair
  /// @param _tokenB Second token in the pair
  /// @param _wrapperName Name of oracle wrapper to quote
  function setPairWrapper(
    address _tokenA,
    address _tokenB,
    string memory _wrapperName
  ) external checkWrapper(_wrapperName) onlyOwner {
    pairWrappers[_tokenA][_tokenB] = wrapperRegistry[_wrapperName];
    pairWrappers[_tokenB][_tokenA] = wrapperRegistry[_wrapperName];
  }

  /// @dev Sets wrapper for a given token, if the token is quoted then this price is returned if no pair is set
  /// @param _token token whose wrapper is set
  /// @param _wrapperName Name of oracle wrapper to quote
  function setTokenWrapper(address _token, string memory _wrapperName) external checkWrapper(_wrapperName) onlyOwner {
    tokenWrappers[_token] = wrapperRegistry[_wrapperName];
  }

  /// @dev Sets default, if the token and pair aren't registered then this is quoted as a last resort
  /// @param _wrapperName Name of oracle wrapper to quote
  function setDefaultWrapper(string memory _wrapperName) external checkWrapper(_wrapperName) onlyOwner {
    defaultWrapper = wrapperRegistry[_wrapperName];
  }

  /// @dev Queries on-chain price data through a shared interface
  /// @dev Pairs have priority over tokens and tokens over the default, which is the last resort
  /// @param _tokenIn Token to be 'swapped' out of
  /// @param _amountIn Amount of input token
  /// @param _tokenOut Token to be 'swapped' into
  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) public view returns (uint256 _amountOut) {
    if (address(pairWrappers[_tokenIn][_tokenOut]) != address(0)) {
      return pairWrappers[_tokenIn][_tokenOut].getAmountOut(_tokenIn, _amountIn, _tokenOut);
    } else if (address(tokenWrappers[_tokenIn]) != address(0)) {
      return tokenWrappers[_tokenIn].getAmountOut(_tokenIn, _amountIn, _tokenOut);
    } else if (address(defaultWrapper) != address(0)) {
      return defaultWrapper.getAmountOut(_tokenIn, _amountIn, _tokenOut);
    }

    revert NoWrapperSet();
  }
}
