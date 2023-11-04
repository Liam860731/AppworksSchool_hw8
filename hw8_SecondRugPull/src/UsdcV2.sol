// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import { FiatTokenV1, SafeMath } from "./UsdcV1.sol";
import "oz/utils/cryptography/MerkleProof.sol";


contract UsdcV2 is FiatTokenV1{
    using SafeMath for uint256;
    bytes32 private merkleRoot;   

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function inWhitelist(bytes32[] memory _merkleProof, address _who) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_who));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }
    modifier onlyWhitelist(bytes32[] memory _merkleProof) {
        require(inWhitelist(_merkleProof, msg.sender),"Whitelist: Invalid proof.");
        _;
    }

    function mintV2(uint256 _amount, bytes32[] memory _merkleProof) 
        external 
        onlyWhitelist(_merkleProof)
    {
        require(_amount > 0, "mintV2: mint amount not greater than 0");
        // Mint the token to the user
        totalSupply_ = totalSupply_.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

    function transferV2(address to, uint256 value, bytes32[] memory _merkleProof) 
        external 
        onlyWhitelist(_merkleProof)
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    //不讓用戶用原本的function轉帳
    function transfer(address to, uint256 value) external override returns (bool) {}
    function transferFrom(address from,address to,uint256 value) external override returns (bool) {}

}

