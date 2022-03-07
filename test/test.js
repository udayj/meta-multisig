const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MetaMultisig", function() {

  it("Should setup the multi-sig wallet and verify signature based transaction", async function() {

    const [wallet1, wallet2, wallet3, wallet4] = await ethers.getSigners();

    const Multisig = await ethers.getContractFactory("MetaMultisig");
    let numSigRequired = 2;
    const multisig_wallet = await Multisig.deploy(numSigRequired);
    
    await multisig_wallet.deployed();
    const addr2 = await wallet2.getAddress();
    const addr3 = await wallet3.getAddress();
    const addr4 = await wallet4.getAddress();
    //add addresses 2 and 3 as owners
    let tx = await multisig_wallet.addOwner(addr2);
    tx = await multisig_wallet.addOwner(addr3);

    let sendFundTx = {
      to: multisig_wallet.address,
      value: ethers.utils.parseUnits("1","ether")
    }
    // fund wallet with 1 ether
    await wallet1.sendTransaction(sendFundTx);
    
    
    let abiCoder = new ethers.utils.AbiCoder();
    let val = abiCoder.encode(["uint256"],[ethers.utils.parseUnits("1","ether")]);
    val = ethers.utils.arrayify(val);

    let addr1_bytes =abiCoder.encode(["address"],[multisig_wallet.address]);
    let addr4_bytes =abiCoder.encode(["address"],[addr4]); 
  
    let val_nonce = abiCoder.encode(["uint256"],[0]);
    val_nonce = ethers.utils.arrayify(val_nonce);
    let final_raw_message = ethers.utils.concat([addr4_bytes,val,val_nonce,addr1_bytes]);
  
   
    //this is the message hash that will be signed using eip-191  
    let message_hash = ethers.utils.keccak256(final_raw_message);
    
    let message_hash_bytes = ethers.utils.arrayify(message_hash);

    //signature of wallet1
    let sig1 = await wallet1.signMessage(message_hash_bytes);

    
    let addr1 = await wallet1.getAddress();
    //signature of wallet 2
    let sig2 = await wallet2.signMessage(message_hash_bytes);

    let signatures = [sig1,sig2];
    let addresses = [addr1,addr2];

    let balance = await wallet4.getBalance();
    expect(balance).to.equal(ethers.utils.parseUnits("10000","ether"));

    tx = await multisig_wallet.sendWithSign(signatures,addresses,addr4,ethers.utils.parseUnits("1","ether"),0);
    //console.log(tx);


    balance = await wallet4.getBalance();
    console.log(balance);
    expect(balance).to.equal(ethers.utils.parseUnits("10001","ether"));

    
    
  });
});


