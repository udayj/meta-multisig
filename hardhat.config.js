require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  networks: {
    hardhat : {
      chainId:1337
    },
    mumbai : {
      url : 'https://eth-rinkeby.alchemyapi.io/v2/TzL04FnJ8Nk1b7Nv7bfZ9NCx2iEdyLH3',
      accounts: ['dfba9a184b65cbe78209e907eabb40896c21cb8c1850a39a5ff503c015e64641'],
    }
  },
};
