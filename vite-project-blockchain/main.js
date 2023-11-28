import "./style.css";

import { createPublicClient, http, getContract, formatUnits, createWalletClient, custom, parseUnits } from "viem";
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

const zombieData = await zombieContract.read.zombies([await zombieContract.read.getZombiesByOwner([account])]);

document.querySelector("#app").innerHTML = `
  <div>
    <span id="blockNumber">Current block is ${blockNumber}</span>
    <p>Contract owner : ${await zombieContract.read.owner()}</p>
    <div id="creation">
      <p>Zombie name : <input id="zombieName"></input></p>
      <button id="createZombie">Create</button>
    </div>
    <p id="balance">Zombie count of <b>${await [account]}</b> : ${await zombieContract.read.balanceOf([account])}</p>
    <div id="allZombies">
      <p>My zombies :</p>
      <ul>
        ${await zombieData.map(data => `<li>${data}</li>`).join('\n')}
      </ul>
    </div>
  </div>
`;

document.querySelector("#createZombie").addEventListener("click", async () => {
  const name = document.querySelector("#zombieName").value;
  const newZombie = await zombieContract.write.createRandomZombie([name]);
});

