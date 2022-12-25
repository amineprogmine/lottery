const { network, ethers } = require("hardhat")
const { networkConfig, developmentChains } = require("../helperHardhatConfig")
const { verify } = require("../utils/verify")

const SUB_AMOUNT = ethers.utils.parseEther("30")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    // const ethUsdPriceFeed = networkConfig[chainId]["ethUsdPriceFeed"]
    let vrfCoordinatorV2Address, subscriptionId

    const entranceFee = networkConfig[chainId]["entranceFee"]
    const gasLane = networkConfig[chainId]["gasLane"]
    const callBackGasLimit = networkConfig[chainId]["callBackGasLimit"]
    const interval = networkConfig[chainId]["interval"]

    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2 = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2.address
        const transactionResponse = await vrfCoordinatorV2.createSubscription()
        const transactionReceipt = await transactionResponse.wait(1)
        subscriptionId = transactionReceipt.events[0].args.subId
        await vrfCoordinatorV2.fundSubscription(subscriptionId, SUB_AMOUNT)
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId]["VRFCoordinatorV2"]
        subscriptionId = networkConfig[chainId]["subscriptionId"]
    }

    /*    address vrfCoordinatorV2,
        uint256 entranceFee,        
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval */

    const args = [
        vrfCoordinatorV2Address,
        entranceFee,
        gasLane,
        subscriptionId,
        callBackGasLimit,
        interval,
    ]
    const Raffle = await deploy("Lottery", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockconfirmations || 1,
    })

    if (!developmentChains.includes(network.name)) {
        log("verifying........")
        await verify(Raffle.address, args)
    }
    log("----------------------------")
}

module.exports.tags = ["all", "lottery"]
