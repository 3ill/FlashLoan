// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract Dex {
    address payable public owner;

    //? token addresses
    address private immutable daiAddress =
        0xBa8DCeD3512925e52FE67b1b5329187589072A55;
    address private immutable usdcAddress =
        0x65aFADD39029741B3b8f0756952C74678c9cEC93;

    IERC20 private dai;
    IERC20 private usdc;

    //? decentralized exchange rate
    uint256 dexARate = 90;
    uint256 dexBRate = 100;

    mapping(address => uint256) daiBalance;
    mapping(address => uint256) usdcBalance;

    constructor() {
        owner = payable(msg.sender);
        dai = IERC20(daiAddress);
        usdc = IERC20(usdcAddress);
    }

    function depositUSDC(uint256 _amount) external {
        usdcBalance[msg.sender] += _amount;
        uint256 allowance = usdc.allowance(msg.sender, address(this));
        require(allowance >= _amount, "check the token allowance");

        usdc.transferFrom(msg.sender, address(this), _amount);
    }

    function depositDAI(uint256 _amount) external {
        daiBalance[msg.sender] += _amount;
        uint256 allowance = dai.allowance(msg.sender, address(this));

        require(allowance >= _amount, "check the token allownace");
        dai.transferFrom(msg.sender, address(this), _amount);
    }

    function buyDAI() external {
        uint256 daiToReceive = ((usdcBalance[msg.sender] / dexARate) * 100) *
            (10 ** 12);

        dai.transfer(msg.sender, daiToReceive);
    }

    function sellDAI() external {
        uint256 usdcToReceive = ((daiBalance[msg.sender] / dexBRate) * 100) *
            (10 ** 12);

        usdc.transfer(msg.sender, usdcToReceive);
    }
}
