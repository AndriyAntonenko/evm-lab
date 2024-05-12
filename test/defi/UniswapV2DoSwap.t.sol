// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UniswapV2DoSwap } from "../../src/defi/UniswapV2DoSwap.sol";

contract UniswapV2DoSwapTest is Test {
  address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address private constant DAI_WHALE = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;
  address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

  address private immutable sender = makeAddr("sender");
  address private immutable receiver = makeAddr("receiver");

  UniswapV2DoSwap private doSwap;

  function setUp() public {
    doSwap = new UniswapV2DoSwap();
  }

  function testUniswapV2DoSwap() public {
    uint256 amountIn = 1_000_000 * 1e18;
    uint256 amountOutMin = 1; // minimum 1 WBTC
    address tokenIn = DAI;
    address tokenOut = WBTC;
    address to = receiver;

    vm.startPrank(DAI_WHALE);
    IERC20(DAI).approve(address(doSwap), amountIn);
    doSwap.swap(tokenIn, tokenOut, amountIn, amountOutMin, to);
    vm.stopPrank();

    console.log("receiver WBTC balance", IERC20(WBTC).balanceOf(receiver));
    assert(IERC20(WBTC).balanceOf(receiver) >= amountOutMin);
  }
}
