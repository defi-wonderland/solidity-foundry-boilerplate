// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

contract InternalCallsVerfier {
  function calledInternal(bytes memory _encodedCall) external view {}
}

contract InternalCallsVerifierExtension {
  InternalCallsVerfier public verifier;

  constructor() {
    verifier = new InternalCallsVerfier();
  }
}
