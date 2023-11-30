pragma solidity ^0.8.19;

import {IKeep3rV2} from '../../interfaces/Swapper/IKeep3rV2.sol';
import {IWETH} from '../../interfaces/Swapper/IWETH.sol';

contract Keeper {
  error KeeperNotValid();
  error JobNotReady();

  uint256 lastWorked;
  address keep3r = 0xdc02981c9C062d48a9bD54adBf51b816623dcc6E;
  uint256 constant TEN_MINUTES = 600;

  IWETH constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  modifier validateAndPayKeeper(address _keeper) {
    if (!IKeep3rV2(keep3r).isKeeper(_keeper)) revert KeeperNotValid();
    _;
    IKeep3rV2(keep3r).directTokenPayment(address(WETH), _keeper, 1e17);
  }

  function work() external validateAndPayKeeper(msg.sender) {
    if (!workable()) {
      revert JobNotReady();
    }

    lastWorked = block.timestamp;

    swap();
  }

  function workable() public view returns (bool _workable) {
    return block.timestamp >= lastWorked + TEN_MINUTES;
  }

  function swap() public virtual {}
}
