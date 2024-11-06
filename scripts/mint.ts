import hre from "hardhat"

async function main() {
  const mintFactory = await hre.ethers.getContractAt('MinterFactory', "0x5885debAC7721260847dF19bb14398543d0A8A1D")
  const nftAddress = '0x145913a4ce0abf4f58689a23fbe08217bccfeeac'

  // Function signature for `mint(uint256)`
  const functionSignature = "mint(uint256)"

  // Use ethers.js to get the function selector from the signature
  const functionSelector = hre.ethers.id(functionSignature).substring(0, 10) // This gives us the first 4 bytes of the hash

  // Amount to mint, for example, 1
  const amountToMint = 1

  // Encoding the parameters. In this case, the amount to mint
  const encodedParams = hre.ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amountToMint])

  // Preparing the data for the call
  // This combines the function signature with the encoded parameters
  const data = functionSelector + encodedParams.substring(2)

  await (await mintFactory.batchMint(10, hre.ethers.parseEther('0.5'), nftAddress, data, { value: hre.ethers.parseEther('5') })).wait()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
