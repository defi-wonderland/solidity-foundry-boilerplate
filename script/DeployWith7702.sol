// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Greeter} from 'contracts/Greeter.sol';
import {Script} from 'forge-std/Script.sol';

import {Vm} from 'forge-std/Vm.sol';
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
      DeploymentParams('Hello, Sepolia!', IERC20(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14));
  }

  function run() public {
    DeploymentParams memory _params = _deploymentParams[block.chainid];

    /// @notice Must use private key for delegator given the signAndAttachDelegation cheatcode below
    uint256 _delegatorPrivateKey = vm.envUint('DELEGATOR_PK');
    address _delegator = vm.addr(_delegatorPrivateKey);

    /// @notice Uses Deployer's account to deploy the contract and interact with Delegator's address
    vm.startBroadcast();

    /// @notice Deployer deploys Greeter contract
    Greeter _greeter = new Greeter(_params.greeting, _params.token);

    /// @notice Delegator signs and attaches the delegation in one step
    Vm.SignedDelegation memory signedDelegation = vm.signDelegation(address(_greeter), _delegatorPrivateKey);
    vm.attachDelegation(signedDelegation);

    /// @notice Deployer calls greet through the delegator (using 7702 delegation)
    Greeter(_delegator).greet();
    vm.stopBroadcast();
  }
}
