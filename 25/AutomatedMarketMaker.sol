// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomatedMarketMaker {
    uint public reserveA;
    uint public reserveB;

    mapping(address => uint) public liquidity;

    function addLiquidity(uint amountA, uint amountB) public {
        require(amountA > 0 && amountB > 0, "Invalid amounts");

        reserveA += amountA;
        reserveB += amountB;
        liquidity[msg.sender] += amountA + amountB;
    }

    function removeLiquidity(uint amount) public {
        require(liquidity[msg.sender] >= amount, "Not enough liquidity");
        require(amount > 0, "Invalid amount");

        uint amountA = (reserveA * amount) / (reserveA + reserveB);
        uint amountB = (reserveB * amount) / (reserveA + reserveB);

        liquidity[msg.sender] -= amount;
        reserveA -= amountA;
        reserveB -= amountB;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure returns (uint) {
        require(amountIn > 0, "Invalid input");
        require(reserveIn > 0 && reserveOut > 0, "Invalid reserves");

        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    function swapAForB(uint amountAIn) public returns (uint amountBOut) {
        amountBOut = getAmountOut(amountAIn, reserveA, reserveB);
        require(amountBOut <= reserveB, "Not enough liquidity");

        reserveA += amountAIn;
        reserveB -= amountBOut;
    }

    function swapBForA(uint amountBIn) public returns (uint amountAOut) {
        amountAOut = getAmountOut(amountBIn, reserveB, reserveA);
        require(amountAOut <= reserveA, "Not enough liquidity");

        reserveB += amountBIn;
        reserveA -= amountAOut;
    }

    function getK() public view returns (uint) {
        return reserveA * reserveB;
    }
}