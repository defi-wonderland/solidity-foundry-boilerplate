// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

contract InternalCallsVerifier {
  function calledInternal(bytes memory _encodedCall) external view {}
}

contract InternalCallsVerifierExtension {
  InternalCallsVerifier public verifier;

  constructor() {
    verifier = new InternalCallsVerifier();
  }
}
