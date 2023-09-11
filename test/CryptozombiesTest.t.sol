// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Contract.sol";

contract CryptozombiesTest is Test {
    function setUp() public {}

    function testLesson1Chapter2() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        assertTrue(address(zombieFactory) != address(0));
    }
}
