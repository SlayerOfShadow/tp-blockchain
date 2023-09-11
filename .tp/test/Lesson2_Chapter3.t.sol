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

    function testLesson1Chapter12() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        zombieFactory.createRandomZombie("Zombie 2600");
        (string memory name, uint dna) = zombieFactory.zombies(0);
        assertEq(name, "Zombie 2600");
        assertEq(
            dna,
            uint(keccak256(abi.encodePacked("Zombie 2600"))) % (10 ** 16)
        );

        zombieFactory.createRandomZombie("Bizon");
        (name, dna) = zombieFactory.zombies(1);
        assertEq(name, "Bizon");
        assertEq(dna, uint(keccak256(abi.encodePacked("Bizon"))) % (10 ** 16));
    }

    event NewZombie(uint zombieId, string name, uint dna);

    function testLesson1Chapter13() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        vm.expectEmit(true, true, true, true, address(zombieFactory));
        emit NewZombie(
            0,
            "Zombie 2600",
            uint(keccak256(abi.encodePacked("Zombie 2600"))) % (10 ** 16)
        );
        zombieFactory.createRandomZombie("Zombie 2600");

        vm.expectEmit(true, true, true, true, address(zombieFactory));
        emit NewZombie(
            1,
            "Bizon",
            uint(keccak256(abi.encodePacked("Bizon"))) % (10 ** 16)
        );
        zombieFactory.createRandomZombie("Bizon");
    }

    function testLesson2Chapter2() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        assertEq(zombieFactory.zombieToOwner(0), address(0));
    }

    function testLesson2Chapter3() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        zombieFactory.createRandomZombie("Zombie 2600");
        assertEq(zombieFactory.zombieToOwner(0), address(this));

        // Check zombie count:
        assertEq(
            uint(
                vm.load(
                    address(zombieFactory),
                    bytes32(
                        uint(
                            keccak256(
                                abi.encode(address(this), 4) // 4 is the slot of ownerZombieCount in ZombieFactory, and we are looking for address(this) key
                            )
                        )
                    )
                )
            ),
            1
        );

        vm.prank(address(42));
        zombieFactory.createRandomZombie("Bizon");
        assertEq(zombieFactory.zombieToOwner(1), address(42));

        vm.prank(address(42));
        zombieFactory.createRandomZombie("Bizon2");
        assertEq(zombieFactory.zombieToOwner(2), address(42));

        // Check zombie count:
        assertEq(
            uint(
                vm.load(
                    address(zombieFactory),
                    bytes32(
                        uint(
                            keccak256(
                                abi.encode(address(42), 4) // 4 is the slot of ownerZombieCount in ZombieFactory, and we are looking for address(42) key
                            )
                        )
                    )
                )
            ),
            2
        );
    }
}
