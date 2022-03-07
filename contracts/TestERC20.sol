//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20{

    constructor(uint initialSupply) ERC20("Test Token","TTK") {

        _mint(msg.sender,initialSupply);
    }
}