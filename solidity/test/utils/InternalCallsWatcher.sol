// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

contract InternalCallsWatcher {
  function calledInternal(bytes memory _encodedCall) external view {}
}

contract InternalCallsWatcherExtension {
  InternalCallsWatcher public watcher;

  constructor() {
    watcher = new InternalCallsWatcher();
  }

  function calledInternal(bytes memory _encodedCall) internal view {
    watcher.calledInternal(_encodedCall);
  }
}
