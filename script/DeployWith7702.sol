// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Greeter} from 'contracts/Greeter.sol';
import {Script} from 'forge-std/Script.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

contract DeployWith7702 is Script {
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

    /// @notice Must use private key given the signAndAttachDelegation cheatcode
    uint256 _deployerPrivateKey = vm.envUint('DEPLOYER_PK');
    vm.startBroadcast(_deployerPrivateKey);
    address _greeter = address(new Greeter(_params.greeting, _params.token));
    /// @notice Signs and attaches the delegation in one step
    vm.signAndAttachDelegation(_greeter, _deployerPrivateKey);
    vm.stopBroadcast();
  }
}
