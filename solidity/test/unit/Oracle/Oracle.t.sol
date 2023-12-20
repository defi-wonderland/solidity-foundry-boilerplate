// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from 'forge-std/Test.sol';
import {Oracle} from '../../../contracts/Oracle/Oracle.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract OracleTest is Test {
  Oracle public oracle;

  IERC20 dai;
  IERC20 uni;
  IERC20 usdt;

  function setUp() public {
    vm.createSelectFork(vm.envString('MAINNET_RPC'));
    dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI token
    uni = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984); // UNI token
    usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT token

    oracle = new Oracle();
  }

  function testPriority() public {
    oracle.registerWrapper('UniswapV2', _wrapper);
    oracle.registerWrapper('Curve', _wrapper);
    oracle.registerWrapper('1Inch', _wrapper);
  }
}
