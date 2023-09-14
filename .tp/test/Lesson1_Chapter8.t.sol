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

    function testLesson1Chapter3() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        assertEq(
            vm.load(address(zombieFactory), bytes32(uint(0))),
            bytes32(uint(16))
        );
    }

    function testLesson1Chapter4() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        assertEq(
            vm.load(address(zombieFactory), bytes32(uint(1))),
            bytes32(uint(10 ** 16))
        );
    }

    function testLesson1Chapter6() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        vm.expectRevert();
        zombieFactory.zombies(0); // This should compile but revert because the array is empty
    }

    function testLesson1Chapter8() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        zombieFactory.createZombie("Zombie 2600", 42);
        (string memory name, uint dna) = zombieFactory.zombies(0);
        assertEq(name, "Zombie 2600");
        assertEq(dna, 42);

        zombieFactory.createZombie("Bizon", 24);
        (name, dna) = zombieFactory.zombies(1);
        assertEq(name, "Bizon");
        assertEq(dna, 24);
    }
}
