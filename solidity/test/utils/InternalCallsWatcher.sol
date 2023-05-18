// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

contract InternalCallsWatcher {
  function calledInternal(bytes memory _encodedCall) external view {}
}

contract InternalCallsWatcherExtension {
  InternalCallsWatcher public watcher;
  bool internal _callSuper = true;

  constructor() {
    watcher = new InternalCallsWatcher();
  }

  function _calledInternal(bytes memory _encodedCall) internal view {
    watcher.calledInternal(_encodedCall);
  }

  function setCallSuper(bool __callSuper) external {
    _callSuper = __callSuper;
  }
}
