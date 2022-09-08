// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import {console} from 'forge-std/console.sol';
import {PRBTest} from 'prb/test/PRBTest.sol';

contract DSTestFull is PRBTest {
    // Seed for the generation of pseudorandom addresses
    bytes32 private nextAddressSeed = keccak256(abi.encodePacked('address'));

    /**
     * @dev Creates a new pseudorandom address and labels it with the given label
     * @param name Name of the label.
     * @return Address generated and labeled
     */
    function label(string memory name) internal returns (address) {
        return label(newAddress(), name);
    }

    /**
     * @dev Labels the given address and returns it
     *
     * @param addy Address to label.
     * @param name Name of the label.
     *
     * @return Address Labeled address
     */
    function label(address addy, string memory name) internal returns (address) {
        vm.label(addy, name);
        return addy;
    }

    /**
     * @dev Creates a mock contract in a pseudorandom address and labels it.
     * @param name Label for the mock contract.
     * @return Address of the mock contract.
     */
    function mockContract(string memory name) internal returns (address) {
        return mockContract(newAddress(), name);
    }

    /**
     * @dev Creates a mock contract in a specified address and labels it.
     *
     * @param addy Address for the mock contract.
     * @param name Label for the mock contract.
     *
     * @return Address of the mock contract.
     */
    function mockContract(address addy, string memory name) internal returns (address) {
        vm.etch(addy, new bytes(0x1));
        return label(addy, name);
    }

    /**
     * @dev Creates a pseudorandom address.
     * @return Address of the mock contract.
     */
    function newAddress() internal returns (address) {
        address payable nextAddress = payable(address(uint160(uint256(nextAddressSeed))));
        nextAddressSeed = keccak256(abi.encodePacked(nextAddressSeed));
        return nextAddress;
    }

    function expectEmitNoIndex() internal {
        vm.expectEmit(false, false, false, true);
    }
}
