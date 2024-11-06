import hre from "hardhat"

async function main() {
  const [owner] = await hre.ethers.getSigners()
  const MinterFactory = await hre.ethers.getContractFactory("NFTMinter")
  const NFTMinter = await MinterFactory.deploy()
  const Factory = await hre.ethers.getContractFactory("MinterFactory")
  const minterFactory = await Factory.deploy(await NFTMinter.getAddress(), 10)

  console.log("NFTMinter factory deployed to:", await minterFactory.getAddress())
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
