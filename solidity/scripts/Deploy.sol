// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import {Script} from 'forge-std/Script.sol';
import {Greeter} from 'contracts/Greeter.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

abstract contract Deploy is Script {
  function _deploy(string memory greeting, IERC20 token) internal {
    vm.startBroadcast();
    new Greeter(greeting, token);
    vm.stopBroadcast();
  }
}

contract DeployMainnet is Deploy {
  function run() external {
    IERC20 weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    _deploy('some real greeting', weth);
  }
}

contract DeployRinkeby is Deploy {
  function run() external {
    IERC20 weth = IERC20(0xDf032Bc4B9dC2782Bb09352007D4C57B75160B15);

    _deploy('some test greeting', weth);
  }
}
