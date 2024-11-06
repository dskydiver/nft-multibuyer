import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs"
import { expect } from "chai"
import hre from "hardhat"

describe("Mint", function () {
  async function deployFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners()
    const MinterFactory = await hre.ethers.getContractFactory("NFTMinter")
    const NFTMinter = await MinterFactory.deploy()
    const Factory = await hre.ethers.getContractFactory("MinterFactory")
    const minterFactory = await Factory.deploy(await NFTMinter.getAddress(), 10)

    const NFTFactory = await hre.ethers.getContractFactory("NFT")
    const nft = await NFTFactory.deploy('baseuri')

    return { minterFactory, owner, otherAccount, nft }
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { minterFactory, owner } = await loadFixture(deployFixture)
      expect(await minterFactory.owner()).to.equal(owner.address)
    })

    it("mint nfts", async function () {
      const { minterFactory, owner, otherAccount, nft } = await loadFixture(deployFixture)
      await (await nft.mint(1, { value: hre.ethers.parseEther('0.001') })).wait()
      console.log(await nft.balanceOf(owner.address))

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
      const data = functionSelector + encodedParams.substring(2) // Remove 0x prefix

      // Value to send, e.g., 0.1 Ether, converted to Wei
      const valueToSend = hre.ethers.parseEther("0.01")

      await (await minterFactory.batchMint(10, hre.ethers.parseEther('0.001'), await nft.getAddress(), data, { value: valueToSend })).wait()
    })
  })
})