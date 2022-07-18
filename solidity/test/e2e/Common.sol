// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "test/utils/DSTestFull.sol";
import "forge-std/console.sol";
import "isolmate/interfaces/tokens/IERC20.sol";

import "contracts/Greeter.sol";

contract CommonE2EBase is DSTestFull {
    string initialGreeting = "hola";
    address user = label("user");
    address owner = label("owner");
    address daiWhale = 0x42f8CA49E88A8fd8F0bfA2C739e648468b8f9dec;
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IGreeter greeter;

    function setUp() public {
        vm.prank(owner);
        greeter = new Greeter(initialGreeting, dai);
    }
}
