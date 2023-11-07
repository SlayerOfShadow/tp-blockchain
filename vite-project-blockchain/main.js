import "./style.css";

// 1. Import modules.
import { createPublicClient, http, getContract, formatUnits, createWalletClient, custom, parseUnits } from "viem";
import { goerli } from "viem/chains";
import { UNI } from "./abi/UNI";

// 2. Set up your client with desired chain & transport.
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

const uniContract = getContract({
  address: "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
  abi: UNI,
  publicClient,
  walletClient,
});

// 3. Consume an action!
const decimals = await uniContract.read.decimals();

const blockNumber = await publicClient.getBlockNumber();

const unwatch = publicClient.watchBlockNumber( 
  { onBlockNumber: blockNumber => document.querySelector("#blockNumber").innerHTML = `
  Current block is ${blockNumber}
  `}
)

document.querySelector("#app").innerHTML = `
  <div>
    <span id="blockNumber">Current block is ${blockNumber}</span>
    <h1>Token ${await uniContract.read.symbol()}</h1>
    <p>Name : ${await uniContract.read.name()}</p>
    <a href="https://goerli.etherscan.io/token/0x1f9840a85d5af5bf1d1762f925bdaddc4201f984">Address : ${uniContract.address}</a>
    <p>Total Supply : ${formatUnits(await uniContract.read.totalSupply(), decimals)}</p>
    <p id="balance">Balance of 0x3FACd9B7E044d13830AEE917662CEb2EC6174514 : ${formatUnits(await uniContract.read.balanceOf(["0x3FACd9B7E044d13830AEE917662CEb2EC6174514"]), decimals)}</p>
    <div id="amount">
      <p>Amount : <input id="amountInput"></input></p>
      <button id="maxButton">Max</button>
    </div>
    <div id="recipient">
      <p>Recipient : <input id="recipientInput"></input></p>
      <button id="sendButton">Send</button>
    </div>
    <span id="transaction"></span>
  </div>
`;

document.querySelector("#maxButton").addEventListener("click", async () => {
  document.querySelector("#amountInput").value = formatUnits(await uniContract.read.balanceOf(["0x3FACd9B7E044d13830AEE917662CEb2EC6174514"]), decimals);
});

document.querySelector("#sendButton").addEventListener("click", async () => {
  const amount = parseUnits(document.querySelector("#amountInput").value, decimals);
  const recipient = document.querySelector("#recipientInput").value;
  const hash = await uniContract.write.transfer([recipient, amount]);
  document.querySelector("#transaction").innerHTML = `Waiting for tx <a href="https://goerli.etherscan.io/tx/${hash}">${hash}</a>`;
  const transaction = await publicClient.waitForTransactionReceipt({ hash: `${hash}` });
    if (transaction.status == "success") {
        document.querySelector("#transaction").innerHTML = `Transaction <a href="https://goerli.etherscan.io/tx/${hash}">${hash}</a> confirmed!`;
    } else {
        document.querySelector("#transaction").innerHTML = `Transaction <a href="https://goerli.etherscan.io/tx/${hash}">${hash}</a> failed!`;
    };
});