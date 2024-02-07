// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Greeter} from 'contracts/Greeter.sol';
import {Script} from 'forge-std/Script.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract Deploy is Script {
  struct DeploymentParams {
    string greeting;
    IERC20 token;
  }

  /// @notice Deployment parameters for each chain
  mapping(uint256 _chainId => DeploymentParams _params) internal _deploymentParams;

  function setUp() public {
    // Mainnet
    _deploymentParams[1] = DeploymentParams('Hello, Mainnet!', IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));

    // Sepolia
    _deploymentParams[11_155_111] =
      DeploymentParams('Hello, Sepolia!', IERC20(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6));
  }

  function run() public {
    DeploymentParams memory _params = _deploymentParams[block.chainid];

    vm.startBroadcast();
    new Greeter(_params.greeting, _params.token);
    vm.stopBroadcast();
  }
}
