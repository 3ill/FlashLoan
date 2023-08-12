// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

interface IDex {
    function depositUSDC(uint256 _amount) external;

    function depositDAI(uint256 _amount) external;

    function buyDAI() external;

    function sellDAI() external;
}

contract FlashloanArbtirage is FlashLoanSimpleReceiverBase {
    address payable owner;
    //? token addresses
    address private immutable daiAddress =
        0xBa8DCeD3512925e52FE67b1b5329187589072A55;
    address private immutable usdcAddress =
        0x65aFADD39029741B3b8f0756952C74678c9cEC93;
    address private immutable dexContractAddress =
        0x3491F72c97b7662a214AE85c9E3876c728e502AE;

    IERC20 private dai;
    IERC20 private usdc;
    IDex private dexContract;

    constructor(
        address _addressProvider
    ) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider)) {
        owner = payable(msg.sender);
        dai = IERC20(daiAddress);
        usdc = IERC20(usdcAddress);
        dexContract = IDex(dexContractAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not contract owner");
        _;
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        //?request flashloan of 1000usdc

        //? Perfrorm abitrage
        //? we deposit the flashloan to the dex contract
        dexContract.depositUSDC(100000000000);

        //? buy some dai at 90% of the USDC
        dexContract.buyDAI();

        //? deposit the dai to the dex contract
        dexContract.depositDAI(dai.balanceOf(address(this)));

        //? sell the dai
        dexContract.sellDAI();

        uint256 amountOwed = amount + premium;
        IERC20(asset).approve(address(POOL), amountOwed);

        return true;
    }

    function approveUSDC(uint256 _amount) external returns (bool) {
        return usdc.approve(dexContractAddress, _amount);
    }

    function allowanceUSDC() external view returns (uint256) {
        return usdc.allowance(address(this), dexContractAddress);
    }

    function approveDAI(uint256 _amount) external returns (bool) {
        return dai.approve(dexContractAddress, _amount);
    }

    function allowanceDAI() external view returns (uint256) {
        return dai.allowance(address(this), dexContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);

        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable {}
}
