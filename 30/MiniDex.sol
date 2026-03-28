// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniDex {
    uint public reserveA;
    uint public reserveB;
    uint public totalLiquidity;

    mapping(address => uint) public liquidityBalance;

    function addLiquidity() public payable returns (uint) {
        require(msg.value > 0, "Send ETH");

        uint liquidityMinted;

        if (totalLiquidity == 0) {
            reserveA += msg.value;
            reserveB += msg.value;
            liquidityMinted = msg.value;
        } else {
            uint ethReserve = reserveA;
            uint tokenAmountRequired = (msg.value * reserveB) / ethReserve;

            reserveA += msg.value;
            reserveB += tokenAmountRequired;

            liquidityMinted = (msg.value * totalLiquidity) / ethReserve;
        }

        liquidityBalance[msg.sender] += liquidityMinted;
        totalLiquidity += liquidityMinted;

        return liquidityMinted;
    }

    function removeLiquidity(uint liquidityAmount) public returns (uint amountA, uint amountB) {
        require(liquidityBalance[msg.sender] >= liquidityAmount, "Not enough liquidity");
        require(liquidityAmount > 0, "Invalid amount");

        amountA = (liquidityAmount * reserveA) / totalLiquidity;
        amountB = (liquidityAmount * reserveB) / totalLiquidity;

        liquidityBalance[msg.sender] -= liquidityAmount;
        totalLiquidity -= liquidityAmount;

        reserveA -= amountA;
        reserveB -= amountB;

        payable(msg.sender).transfer(amountA);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint) {
        require(amountIn > 0, "Invalid input");
        require(reserveIn > 0 && reserveOut > 0, "Invalid reserves");

        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    function swapAForB() public payable returns (uint amountOut) {
        require(msg.value > 0, "Send ETH");

        amountOut = getAmountOut(msg.value, reserveA, reserveB);
        require(amountOut < reserveB, "Not enough liquidity");

        reserveA += msg.value;
        reserveB -= amountOut;
    }

    function swapBForA(uint amountIn) public returns (uint amountOut) {
        require(amountIn > 0, "Invalid amount");

        amountOut = getAmountOut(amountIn, reserveB, reserveA);
        require(amountOut < reserveA, "Not enough liquidity");

        reserveB += amountIn;
        reserveA -= amountOut;

        payable(msg.sender).transfer(amountOut);
    }

    function getK() public view returns (uint) {
        return reserveA * reserveB;
    }

    function getReserves() public view returns (uint, uint) {
        return (reserveA, reserveB);
    }
}