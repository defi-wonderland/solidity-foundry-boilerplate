// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

import {console} from 'forge-std/console.sol';
import {PRBTest} from 'prb/test/PRBTest.sol';

contract DSTestFull is PRBTest {
  // Seed for the generation of pseudorandom addresses
  bytes32 private _nextAddressSeed = keccak256(abi.encodePacked('address'));

  /**
   * @dev Creates a new pseudorandom address and labels it with the given label
   * @param _name Name of the label.
   * @return _address The address generated and labeled
   */
  function _label(string memory _name) internal returns (address _address) {
    return _label(_newAddress(), _name);
  }

  /**
   * @dev Labels the given address and returns it
   *
   * @param _addy Address to label.
   * @param _name Name of the label.
   *
   * @return _address The address Labeled address
   */
  function _label(address _addy, string memory _name) internal returns (address _address) {
    vm.label(_addy, _name);
    return _addy;
  }

  /**
   * @dev Creates a mock contract in a pseudorandom address and labels it.
   * @param _name Label for the mock contract.
   * @return _address The address of the mock contract.
   */
  function _mockContract(string memory _name) internal returns (address _address) {
    return _mockContract(_newAddress(), _name);
  }

  /**
   * @dev Creates a mock contract in a specified address and labels it.
   *
   * @param _addy Address for the mock contract.
   * @param _name Label for the mock contract.
   *
   * @return _address The address of the mock contract.
   */
  function _mockContract(address _addy, string memory _name) internal returns (address _address) {
    vm.etch(_addy, new bytes(0x1));
    return _label(_addy, _name);
  }

  /**
   * @dev Creates a pseudorandom address.
   * @return _address The address of the mock contract.
   */
  function _newAddress() internal returns (address _address) {
    address payable _nextAddress = payable(address(uint160(uint256(_nextAddressSeed))));
    _nextAddressSeed = keccak256(abi.encodePacked(_nextAddressSeed));
    _address = _nextAddress;
  }

  function _expectEmitNoIndex() internal {
    vm.expectEmit(false, false, false, true);
  }
}
