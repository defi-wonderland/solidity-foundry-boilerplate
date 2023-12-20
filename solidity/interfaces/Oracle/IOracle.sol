pragma solidity ^0.8.19;

import {IWrapper} from './IWrapper.sol';

interface IOracle {
  error NoWrapperSet();
  error WrapperNotRegistered();

  event WrapperRegistered(string wrapperName, IWrapper _wrapper);
}
