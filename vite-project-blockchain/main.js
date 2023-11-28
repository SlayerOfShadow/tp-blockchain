import "./style.css";

import { createPublicClient, http, getContract, formatUnits, createWalletClient, custom, parseEther } from "viem";
import { goerli } from "viem/chains";
import { CryptoZombies } from './abi/CryptoZombies';

const [account] = await window.ethereum.request({ method: "eth_requestAccounts" });

const walletClient = createWalletClient({
  account,
  chain: goerli,
  transport: custom(window.ethereum),
});

const publicClient = createPublicClient({
  chain: goerli,
  transport: http(),
});

const zombieContract = getContract({
  address: "0x24feb5A97ABf0328C920E0Ac505D1ff97626cB95",
  abi: CryptoZombies,
  publicClient,
  walletClient,
});

// Variables :

const blockNumber = await publicClient.getBlockNumber();

const zombieCount = await zombieContract.read.balanceOf([account]);

const zombieData = await zombieContract.read.zombies([await zombieContract.read.getZombiesByOwner([account])]);

const getAllZombies = async () => {
  let count = 0;
  let allZombies = [];

  while (true) {
    try {
      const zombie = await zombieContract.read.zombies([count]);
      allZombies.push(zombie);
      count++;
    } catch (error) {
      break;
    }
  }
  return allZombies;
};

const updateZombiesList = async () => {
  const allZombiesData = await getAllZombies();
  allZombiesList.innerHTML = allZombiesData
    .map((zombie) => `<li class="allZombieCard">${zombie.map((data) => `<p>${data}</p>`).join('')}</li>`)
    .join('');
};

updateZombiesList();

document.querySelector("#app").innerHTML = `
  <div>
    <span id="blockNumber">Current block is ${blockNumber}</span>
    <p>Contract owner : ${await zombieContract.read.owner()}</p>
    <div id="creation">
      <p>Zombie name : <input id="zombieName"></input></p>
      <button id="createZombie">Create</button>
    </div>
    <p id="balance">Zombie count of <b>${await [account]}</b> : ${zombieCount}</p>
    <p>My zombies :</p>
    <div id="zombieCard">
      <ul>
        ${await zombieData.map(data => `<li>${data}</li>`).join('\n')}
      </ul>
    </div>
    <button id="levelUp">Level up</button>
    <p>All zombies :</p>
    <div id="allZombies">
      <ul id="allZombiesList"></ul>
    </div>
  </div>
`;

document.querySelector("#createZombie").addEventListener("click", async () => {
  const name = document.querySelector("#zombieName").value;

  // Check if zombieCount is greater than 0
  if (zombieCount > 0) {
    // Display a popup message
    alert("You can't have more than one zombie.");
  } else {
    // Proceed to create a new zombie if both conditions are met
    const newZombie = await zombieContract.write.createRandomZombie([name]);
  }
});

document.querySelector("#levelUp").addEventListener("click", async () => {
  // Check if the user has at least one zombie
  if (zombieCount === 0) {
    alert("You need to create a zombie first.");
    return;
  }

  try {
    // Level up the zombie by paying 0.001 ether
    const levelUpTx = await walletClient.writeContract({
      address: zombieContract.address, // Use the address of your zombie contract
      abi: CryptoZombies,
      functionName: 'levelUp', // Replace with the actual function name for leveling up in your contract
      args: [await zombieContract.read.getZombiesByOwner([account])], // If your levelUp function doesn't require any arguments
      value: parseEther('0.001') // Pay 0.001 ether for leveling up
    });

  } catch (error) {
    console.error("Error while leveling up zombie:", error);
    alert("An error occurred while leveling up the zombie. Please try again.");
  }
});
