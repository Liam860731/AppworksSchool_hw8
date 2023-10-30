// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import { FiatTokenV1 } from "../src/UsdcV1.sol";
import { UsdcV2} from "../src/UsdcV2.sol";
import { Merkle } from "murky/src/Merkle.sol";

contract UsdcTest is Test {

    //Mainnet
    uint256 mainnetFork;
    //USDC of Proxy
    address circleUSDC;
    //Admin of USDC
    address admin;
    //Upgrade logical contract
    UsdcV2 usdcV2;

    //In white list
    address owner;
    address user1 = makeAddr("leaf1");
    Merkle m;
    bytes32[] leaf;
    bytes32 root;

    //Not in white list
    address user2 = makeAddr("leaf2");

    function setUp() public {
        //Connect to mainnet
        mainnetFork = vm.createSelectFork(vm.envString("LOC_MAINNET_RPC_RUL"));
        vm.selectFork(mainnetFork);
        admin = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
        owner = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a;

        //Get initial merkle root
        m = new Merkle();
        leaf = new bytes32[](2);
        leaf[0] = keccak256(abi.encodePacked(owner));
        leaf[1] = keccak256(abi.encodePacked(user1));
        root = m.getRoot(leaf);

        //Deploy USDC
        usdcV2 = new UsdcV2();
        circleUSDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);        
        
    }

    function testUnlimitedMint() public {
        
        //升級合約
        vm.startPrank(admin);
        (bool isUpgrade,) = address(circleUSDC).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV2)));
        require(isUpgrade);
        address V2 = address(circleUSDC);
        vm.stopPrank();

        //set merkle root
        vm.startPrank(owner);
        (bool isSetRoot,) = V2.call(abi.encodeWithSignature("setMerkleRoot(bytes32)", root));
        require(isSetRoot);
        bytes32[] memory proof = m.getProof(leaf, 0);

        //測試白名單 mintV2
        (bool result1,bytes memory value1) = V2.call(abi.encodeWithSignature("balanceOf(address)", owner));
        require(result1);
        uint256 beforeBalanceOf = abi.decode(value1, (uint256));

        (bool isMintV2,) = V2.call(abi.encodeWithSignature("mintV2(uint256,bytes32[])", 3 ether, proof));
        require(isMintV2);

        (bool result2,bytes memory value2) = V2.call(abi.encodeWithSignature("balanceOf(address)", owner));
        require(result2);
        uint256 afterBalanceOf = abi.decode(value2, (uint256));

        assertEq(afterBalanceOf - beforeBalanceOf, 3 ether);

        vm.stopPrank();
        //測試不在白名單 mintV2
        vm.startPrank(user2);
        vm.expectRevert("Whitelist: Invalid proof.");
        (bool isInWhitelist,) = V2.call(abi.encodeWithSignature("mintV2(uint256,bytes32[])", 3 ether, proof));
        require(isInWhitelist);
        vm.stopPrank();

    }
    function testTransfer() public {
        
        //升級合約
        vm.startPrank(admin);
        (bool isUpgrade,) = address(circleUSDC).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV2)));
        require(isUpgrade);
        address V2 = address(circleUSDC);
        vm.stopPrank();

        //set merkle root
        vm.startPrank(owner);
        (bool isSetRoot,) = V2.call(abi.encodeWithSignature("setMerkleRoot(bytes32)", root));
        require(isSetRoot);
        bytes32[] memory proof = m.getProof(leaf, 0);

        //測試白名單 TransferV2
        (bool isMintV2,) = V2.call(abi.encodeWithSignature("mintV2(uint256,bytes32[])", 3 ether, proof));
        require(isMintV2);

        (bool result1,bytes memory value1) = V2.call(abi.encodeWithSignature("balanceOf(address)", user1));
        require(result1);
        uint256 beforeBalanceOf = abi.decode(value1, (uint256));
        
        (bool isTransferV2,) = V2.call(abi.encodeWithSignature("transferV2(address,uint256,bytes32[])", user1, 1 ether, proof));
        require(isTransferV2);

        (bool result2,bytes memory value2) = V2.call(abi.encodeWithSignature("balanceOf(address)", user1));
        require(result2);
        uint256 afterBalanceOf = abi.decode(value2, (uint256));

        assertEq(afterBalanceOf - beforeBalanceOf, 1 ether);
        vm.stopPrank();

        //測試不在白名單 TransferV2
        vm.startPrank(user2);
        vm.expectRevert("Whitelist: Invalid proof.");
        (bool isInWhitelist,) = V2.call(abi.encodeWithSignature("transferV2(address,uint256,bytes32[])", user1, 1 ether, proof));
        require(isInWhitelist);
        vm.stopPrank();

    }

}
