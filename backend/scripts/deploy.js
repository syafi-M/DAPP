import hre from "hardhat";
import fs from "node:fs";
import path from "node:path";

const { ethers } = hre;

async function main() {
  const SMTToken = await ethers.getContractFactory("SMTToken");
  const smtToken = await SMTToken.deploy();
  await smtToken.waitForDeployment();
  const smtAddress = await smtToken.getAddress();

  const GameTopup = await ethers.getContractFactory("GameTopup");
  const gameTopup = await GameTopup.deploy(smtAddress);
  await gameTopup.waitForDeployment();
  const topupAddress = await gameTopup.getAddress();

  console.log(`SMTToken deployed to: ${smtAddress}`);
  console.log(`GameTopup deployed to: ${topupAddress}`);

  const smtArtifact = await hre.artifacts.readArtifact("SMTToken");
  const topupArtifact = await hre.artifacts.readArtifact("GameTopup");
  const outputDir = path.join(process.cwd(), "..", "konektor");
  fs.mkdirSync(outputDir, { recursive: true });
  fs.writeFileSync(
    path.join(outputDir, "contract.json"),
    JSON.stringify(
      {
        network: "Ethereum Hardhat Localhost",
        token: { name: "Sampel Metaverse Token", symbol: "SMT", address: smtAddress, abi: smtArtifact.abi },
        topup: { name: "GameTopup", address: topupAddress, abi: topupArtifact.abi },
      },
      null,
      2
    )
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
