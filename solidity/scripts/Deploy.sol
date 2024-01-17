// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Greeter} from 'contracts/Greeter.sol';
import {Script} from 'forge-std/Script.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

abstract contract DeployHelper is Script {
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

contract Deploy is DeployHelper {
  function run(address _weth) external {
    IERC20 weth = IERC20(_weth);

    _deploy('some test greeting', weth);
  }
}
