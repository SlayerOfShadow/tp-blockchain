// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/zombiefeeding.sol";

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

        vm.prank(address(42));
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
        vm.prank(address(42));
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
            1
        );
    }

    function testLesson2Chapter4() public {
        ZombieFactory zombieFactory = new ZombieFactory();
        zombieFactory.createRandomZombie("Zombie 2600");
        // Only 1 zombie per address:
        vm.expectRevert();
        zombieFactory.createRandomZombie("Zombie 2600 2");

        vm.prank(address(42));
        zombieFactory.createRandomZombie("Bizon");

        // Only 1 zombie per address:
        vm.prank(address(42));
        vm.expectRevert();
        zombieFactory.createRandomZombie("Bizon 2");
    }

    function testLesson2Chapter5() public {
        ZombieFeeding zombieFeeding = new ZombieFeeding();
        assertTrue(address(zombieFeeding) != address(0));
    }

    function testLesson2Chapter7() public {
        ZombieFeeding zombieFeeding = new ZombieFeeding();
        zombieFeeding.createRandomZombie("Zombie 2600");
        uint targetDna = 7;
        zombieFeeding.feedAndMultiply(0, targetDna, "");

        // Another address cannot feed my zombie:
        vm.prank(address(42));
        vm.expectRevert();
        zombieFeeding.feedAndMultiply(0, targetDna, "");
    }

    function testLesson2Chapter9() public {
        ZombieFeeding zombieFeeding = new ZombieFeeding();
        zombieFeeding.createRandomZombie("Zombie 2600");
        uint targetDna = uint(keccak256("TargetDna"));
        zombieFeeding.feedAndMultiply(0, targetDna, "");

        (, uint dna1) = zombieFeeding.zombies(0);
        (string memory name2, uint dna2) = zombieFeeding.zombies(1);

        assertEq(name2, "NoName");
        assertEq(dna2, ((dna1 + (targetDna % 10 ** 16)) / 2));
    }

    function testLesson2Chapter10() public {
        KittyInterface kitty = new FakeKitty();
        (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        ) = kitty.getKitty(42);
        assertEq(isGestating, false);
        assertEq(isReady, true);
        assertEq(cooldownIndex, 1);
        assertEq(nextActionAt, 2);
        assertEq(siringWithId, 3);
        assertEq(birthTime, 4);
        assertEq(matronId, 5);
        assertEq(sireId, 6);
        assertEq(generation, 7);
        assertEq(genes, 42);
    }

    function testLesson2Chapter11() public {
        ZombieFeeding zombieFeeding = new ZombieFeeding();
        assertEq32(
            vm.load(address(zombieFeeding), bytes32(uint(5))),
            bytes32(abi.encode(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d))
        );
        assertEq32(
            vm.load(address(zombieFeeding), bytes32(uint(6))),
            bytes32(abi.encode(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d))
        );
    }

    function testLesson2Chapter12() public {
        ZombieFeeding zombieFeeding = new ZombieFeeding();
        zombieFeeding.createRandomZombie("Zombie 2600");

        uint kittyGene = uint(keccak256("KittyGene"));

        vm.mockCall(
            address(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d),
            abi.encodeWithSelector(KittyInterface.getKitty.selector, 42),
            abi.encode(false, false, 0, 0, 0, 0, 0, 0, 0, kittyGene)
        );

        zombieFeeding.feedOnKitty(0, 42);

        (, uint dna) = zombieFeeding.zombies(0);
        (string memory name2, uint dna2) = zombieFeeding.zombies(1);

        uint expectedNonKittyDna = ((dna + (kittyGene % 10 ** 16)) / 2);
        uint expectedKittyDna = expectedNonKittyDna -
            (expectedNonKittyDna % 100) +
            99;

        assertEq(name2, "NoName");
        assertEq(dna2, expectedKittyDna);
    }

    function testLesson2Chapter13() public {
        ZombieFeeding zombieFeeding = new ZombieFeeding();
        zombieFeeding.createRandomZombie("Zombie 2600");

        uint kittyGene = uint(keccak256("KittyGene"));

        vm.mockCall(
            address(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d),
            abi.encodeWithSelector(KittyInterface.getKitty.selector, 42),
            abi.encode(false, false, 0, 0, 0, 0, 0, 0, 0, kittyGene)
        );

        zombieFeeding.feedOnKitty(0, 42);
        (, uint dna2) = zombieFeeding.zombies(1);
        assertEq(dna2 % 100, 99);
    }
}

contract FakeKitty is KittyInterface {
    function getKitty(
        uint256 _id
    )
        external
        pure
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        )
    {
        isGestating = false;
        isReady = true;
        cooldownIndex = 1;
        nextActionAt = 2;
        siringWithId = 3;
        birthTime = 4;
        matronId = 5;
        sireId = 6;
        generation = 7;
        genes = _id;
    }
}
