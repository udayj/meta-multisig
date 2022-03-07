//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MetaMultisig {


    mapping (address => bool) owners;
    uint public numOwners;
    uint public numSigRequired;
    uint public nonce;
    constructor(uint _numSigRequired) {

        require(_numSigRequired > 0, "Num sig needs to be atleast 1");
        owners[msg.sender]=true;
        numOwners++;
        numSigRequired=_numSigRequired;
    }

    modifier onlyOwner(address _address) {
        require(owners[_address],"Not an owner of this wallet");
        _;
    }

    function addOwner(address _address) 
        public
        onlyOwner(msg.sender) 
    {

        require(!owners[_address],"Already an owner");
        owners[_address]=true;
        numOwners++;
            
    }

    receive() external payable {

    }
    
    function sendWithSign(bytes[] calldata signatures, address[] calldata addresses, address payable addr, uint amount, uint _nonce) 
        public 
        onlyOwner(msg.sender) {

        uint len=signatures.length;
        require(_nonce==nonce,"Nonce invalid");
        nonce++;
        require(amount<=address(this).balance,"Insufficient balance");
        uint numSig=0;
        for(uint i=0;i<len;i++) {

            require(owners[addresses[i]],"Address is not an owner");
            
            bytes32 msgHash = keccak256(abi.encode(addr,amount,_nonce,address(this)));
            bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
            /*console.log("Checking signatures");
            console.logBytes(abi.encode(addr,amount,nonce,address(this)));
            console.logBytes32(msgHash);
            console.logBytes32(message);*/
            require(recoverSigner(message,signatures[i])==addresses[i],"Invalid signature");
            numSig++;

        }
        require(numSig>=numSigRequired,"Not enough signatures");
        addr.transfer(amount);



    }

    function sendWithSignERC20(
        bytes[] calldata signatures, 
        address[] calldata addresses, 
        address payable addr, 
        uint amount, 
        uint _nonce,
        address tokenAddress)
        external
        onlyOwner(msg.sender) {

        
        require(_nonce==nonce,"Nonce invalid");
        nonce++;
        require(amount<=IERC20(tokenAddress).balanceOf(address(this)),"Insufficient balance");


        uint numSig=0;
        for(uint i=0;i<signatures.length;i++) {

            require(owners[addresses[i]],"Address is not an owner");
            
            bytes32 msgHash = keccak256(abi.encode(addr,amount,_nonce,address(this),tokenAddress));
            bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash));
            /*console.log("Checking signatures");
            console.logBytes(abi.encode(addr,amount,nonce,address(this)));
            console.logBytes32(msgHash);
            console.logBytes32(message);*/
            require(recoverSigner(message,signatures[i])==addresses[i],"Invalid signature");
            numSig++;

        }
        require(numSig>=numSigRequired,"Not enough signatures");
        IERC20(tokenAddress).transfer(addr,amount);

    }

    //from solidity-by-example
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    //from solidity-by-example
    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

}